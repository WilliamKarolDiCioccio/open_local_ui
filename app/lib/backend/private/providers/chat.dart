import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/backend/private/storage/chat_sessions.dart';
import 'package:open_local_ui/backend/private/models/chat_message.dart';
import 'package:open_local_ui/backend/private/models/chat_session.dart';
import 'package:open_local_ui/backend/private/providers/ollama_model.dart';
import 'package:open_local_ui/backend/private/providers/model_settings.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

/// A provider class for managing chats in all their aspects.
///
/// This class extends the [ChangeNotifier] class, allowing it to notify listeners when the chat state changes.
///
/// The chat provider is responsible for:
/// - Managing chat sessions
/// - Managing chat messages
/// - Handling chat logic
///
/// This class wraps around the langchain.dart library, which provides us with models, agents, databases and other tools.
class ChatProvider extends ChangeNotifier {
  // Langchain objects
  late ChatOllama _chat;

  // Chat settings
  late String _modelName;
  late bool _showStatistics;
  late ModelSettingsHandler _modelSettingsHandler;

  // Chat session
  ChatSessionWrapperV1? _session;
  final List<ChatSessionWrapperV1> _sessions = [];

  /// Default initializations for late variables are provided in the constructor because the [_init] method runs asynchronously and there is no way to await it in the constructor.
  ChatProvider()
      : _chat = ChatOllama(),
        _modelName = '',
        _showStatistics = false {
    _init();
  }

  /// Called when the provider is initialized to load settings and chat sessions.
  ///
  /// Global override settings are stored using the [SharedPreferences] plugin.
  /// Model specific settings are stored in the app's data directory as JSON files (see [ModelSettingsProvider]).
  /// Chat sessions are stored in the app's data directory using the Hive database (see [ChatSessionsDatabase]).
  ///
  /// Returns a `void`.
  void _init() async {
    final prefs = await SharedPreferences.getInstance();

    final models = GetIt.instance<OllamaModelProvider>().models;
    final modelName = prefs.getString('modelName') ?? '';

    if (models.any((model) => model.name == modelName)) {
      _modelName = modelName;
    } else {
      if (models.isNotEmpty) _modelName = models.first.name;
    }

    _showStatistics = prefs.getBool('showStatistics') ?? false;

    await updateChatOllamaOptions();

    final docsDir = await getApplicationDocumentsDirectory();
    final dataDir = await getApplicationSupportDirectory();

    _sessions.addAll(
      await Isolate.run(
        () async {
          final getIt = GetIt.instance;
          getIt.registerSingleton<ChatSessionsDatabase>(ChatSessionsDatabase());

          // Using Hive.init in the isolate instead of the DB init method due to path_provider initialization issues
          Hive.init('${dataDir.path}/sessions');

          final legacySessionsDir = Directory(
            '${docsDir.path}/OpenLocalUI/saved_data',
          );

          if (legacySessionsDir.existsSync()) {
            final sourceDir = legacySessionsDir;

            final sourceFiles = sourceDir.listSync();

            final destinationDir = Directory('${dataDir.path}/sessions');

            if (!destinationDir.existsSync()) {
              destinationDir.createSync(recursive: true);
            }

            if (sourceFiles.isNotEmpty) {
              for (final file in sourceFiles) {
                File(file.path).copySync(
                  '${destinationDir.path}/${file.path.split(Platform.pathSeparator).last}',
                );
              }
            }

            legacySessionsDir.deleteSync(recursive: true);
          }

          return await GetIt.instance<ChatSessionsDatabase>().loadSessions();
        },
      ),
    );

    notifyListeners();
  }

  ///////////////////////////////////////////
  //          Sessions management          //
  ///////////////////////////////////////////

  /// Adds a new chat session with the given title and saves it to the database.
  ///
  /// Returns the newly created [ChatSessionWrapperV1].
  ChatSessionWrapperV1 addSession(String title) {
    _sessions.add(
      ChatSessionWrapperV1(
        DateTime.now(),
        const Uuid().v4(),
        [],
      ),
    );

    GetIt.instance<ChatSessionsDatabase>().saveSession(_sessions.last);

    notifyListeners();

    return _sessions.last;
  }

  /// Creates a new chat session and sets it as the current session.
  ///
  /// Returns `void`.
  ChatSessionWrapperV1 newSession() {
    final session = addSession('');
    setSession(session.uuid);
    notifyListeners();
    return session;
  }

  /// Sets the current session to the one with the given UUID, loads its chat history and sets the window title.
  ///
  /// If the acrive session is currently generating, the function prevents the session from being changed.
  ///
  /// Returns `void`.
  void setSession(String uuid) {
    if (isGenerating) return;

    clearSessionHistory();

    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _session = _sessions[index];

    () async {
      doWhenWindowReady(() {
        appWindow.title = 'OpenLocalUI - ${_session!.title}';
      });
    }();

    loadSessionHistory();

    for (final message in _session!.messages.reversed) {
      if (message is ChatModelMessageWrapperV1) {
        final models = GetIt.instance<OllamaModelProvider>().models;

        if (models.any(
          (model) => model.name == message.senderName,
        )) {
          setModel(message.senderName!);
        } else {
          setModel(models.first.name);
        }

        break;
      }
    }

    notifyListeners();
  }

  /// Removes the session with the given UUID from the list of sessions and deletes it from the database.
  ///
  /// If the session is active and currently generating, the function prevents the session from being removed.
  ///
  /// Returns `void`.
  void removeSession(String uuid) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    if (_session != null && (uuid == _session!.uuid && isGenerating)) return;

    _sessions.removeAt(index);

    if (isSessionSelected && _session!.uuid == uuid) {
      () async {
        doWhenWindowReady(() async {
          appWindow.title = 'OpenLocalUI';
        });
      }();
    }

    _session = null;

    GetIt.instance<ChatSessionsDatabase>().deleteSession(uuid);

    notifyListeners();
  }

  /// Removes all sessions from the list of sessions and deletes them from the database.
  ///
  /// Under the hood, the function iterates over the list of sessions and removes each session one by one.
  /// This means it follows the same logic as [removeSession] inherits its constraints.
  ///
  /// Returns `void`.
  void clearSessions() {
    final List<String> uuids = [];

    for (final session in _sessions) {
      uuids.add(session.uuid);
    }

    for (final uuid in uuids) {
      removeSession(uuid);
    }
  }

  /// Sets the title of the session with the given UUID to the given title, updates the session in the database and updates the window title if the session is currently active.
  ///
  /// Returns `void`.
  void setSessionTitle(String uuid, String title) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _sessions[index].title = title;

    if (isSessionSelected && _session!.uuid == uuid) {
      () async {
        doWhenWindowReady(() async {
          appWindow.title = 'OpenLocalUI - ${_sessions[index].title}';
        });
      }();
    }

    GetIt.instance<ChatSessionsDatabase>().updateSession(_sessions[index]);

    notifyListeners();
  }

  ///////////////////////////////////////////
  //          Messages management          //
  ///////////////////////////////////////////

  /// Adds a chat message of type system to the current session and to the model's memory and updates the session in the database.
  ///
  /// If the session is not selected, the function returns the newly created [ChatSystemMessageWrapper] without adding it to the memory or the database.
  ///
  /// Returns the newly created [ChatSystemMessageWrapper].
  ChatSystemMessageWrapperV1 addSystemMessage(String message) {
    final chatMessage = ChatSystemMessageWrapperV1(
      message,
      DateTime.now(),
      const Uuid().v4(),
    );

    if (!isSessionSelected) return chatMessage;

    _session!.messages.add(chatMessage);

    // System messages shouldn't be added to the memory

    GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

    notifyListeners();

    return chatMessage;
  }

  /// Adds a chat message of type model to the current session and to the model's memory and updates the session in the database.
  ///
  /// If the session is not selected, the function returns the newly created [ChatModelMessageWrapperV1] without adding it to the memory or the database.
  ///
  /// Returns the newly created [ChatModelMessageWrapperV1].
  Future<ChatModelMessageWrapperV1> addModelMessage(
    Stream<String> messageStream,
    String senderName,
  ) async {
    final StringBuffer messageBuffer = StringBuffer();
    final DateTime timestamp = DateTime.now();
    final String messageId = const Uuid().v4();

    final chatMessage = ChatModelMessageWrapperV1(
      '',
      timestamp,
      messageId,
      senderName,
    );

    _session!.messages.add(chatMessage);

    final completer = Completer<ChatModelMessageWrapperV1>();

    final StreamSubscription<String> subscription = messageStream.listen(
      (message) {
        messageBuffer.write(message);

        _session!.messages.last.text = messageBuffer.toString();
      },
      onDone: () {
        _session!.memory.chatHistory.addAIChatMessage(
          messageBuffer.toString(),
        );

        GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

        completer
            .complete(_session!.messages.last as ChatModelMessageWrapperV1);

        notifyListeners();
      },
      onError: (dynamic error) {
        completer.completeError(error);
      },
    );

    await completer.future;

    await subscription.cancel();

    return _session!.messages.last as ChatModelMessageWrapperV1;
  }

  /// Adds a chat message of type user to the current session and to the model's memory and updates the session in the database.
  ///
  /// If the session is not selected, the function returns the newly created [ChatUserMessageWrapper] without adding it to the memory or the database.
  ///
  /// User messages have optional [imageBytes] attached to them for use in multimodal models.
  ///
  /// Returns the newly created [ChatUserMessageWrapper].
  ChatUserMessageWrapperV1 addUserMessage(
    String message,
    Uint8List? imageBytes,
  ) {
    final chatMessage = ChatUserMessageWrapperV1(
      message,
      DateTime.now(),
      const Uuid().v4(),
      imageBytes: imageBytes,
    );

    if (_session == null) return chatMessage;

    _session!.messages.add(chatMessage);
    _session!.memory.chatHistory.addHumanChatMessage(message);

    GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

    notifyListeners();

    return chatMessage;
  }

  /// Removes the the message with the given UUID and its childs from the current session and from the model's memory and updates the session in the database.
  ///
  /// If the session is active and currently generating, the function prevents the messages from being removed.
  ///
  /// Returns `void`.
  void removeMessage(String uuid) async {
    if (!isSessionSelected || isGenerating) return;

    final index = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    _session!.messages.removeRange(index, messageCount);

    for (var i = 0; i < messageCount - index; ++i) {
      await _session!.memory.chatHistory.removeLast();
    }

    await GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

    notifyListeners();
  }

  /// Removes the last message from the current session and from the model's memory and updates the session in the database.
  ///
  /// If the session is active and currently generating, the function prevents the message from being removed.
  ///
  /// Returns `void`.
  void removeLastMessage() async {
    if (!isSessionSelected || isGenerating || messageCount == 0) {
      return;
    }

    _session!.messages.removeLast();
    await _session!.memory.chatHistory.removeLast();

    await GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

    notifyListeners();
  }

  void clearMessages() async {
    if (!isSessionSelected || isGenerating) return;

    _session!.messages.clear();
    await _session!.memory.chatHistory.clear();

    await GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

    notifyListeners();
  }

  ///////////////////////////////////////////
  //          Chat logic management        //
  ///////////////////////////////////////////

  /// Builds a chat chain that processes the user's input and generates a response.
  @visibleForTesting
  Future<RunnableSequence> buildChain() async {
    final systemPrompt = await _loadSystemPrompt();

    final promptTemplate = ChatPromptTemplate.fromPromptMessages([
      ChatMessagePromptTemplate.system(systemPrompt),
      const MessagesPlaceholder(variableName: 'history'),
      const MessagesPlaceholder(variableName: 'input'),
    ]);

    final chain = Runnable.fromMap({
          'input': Runnable.passthrough(),
          'history': Runnable.fromFunction(
            invoke: (final _, final __) async {
              final m = await _session!.memory.loadMemoryVariables();
              return m['history'];
            },
          ),
        }) |
        promptTemplate |
        _chat;

    return chain;
  }

  /// Use model specific prompt if available, otherwise use default from assets.
  Future<String> _loadSystemPrompt() async {
    if (_modelSettingsHandler.activeModelSettings.systemPrompt != null &&
        _modelSettingsHandler.activeModelSettings.systemPrompt!.isNotEmpty) {
      return _modelSettingsHandler.activeModelSettings.systemPrompt!;
    }

    return rootBundle.loadString('assets/prompts/default.txt');
  }

  /// Builds a prompt message with the given text and optional image bytes.
  ChatMessage _buildPrompt(String text, {Uint8List? imageBytes}) {
    final prompt = ChatMessage.human(
      ChatMessageContent.multiModal(
        [
          ChatMessageContent.text(text),
          if (imageBytes != null)
            ChatMessageContent.image(
              data: base64.encode(
                imageBytes.map((e) => e.toInt()).toList(),
              ),
            ),
        ],
      ),
    );

    return prompt;
  }

  /// Processes the chat chain with the given prompt and streams the response as a string.
  Stream<String> _processChain(ChatMessage prompt) async* {
    final chain = await buildChain();

    await for (final response in chain.stream([prompt])) {
      final result = response as ChatResult;

      _computePerformanceStatistics(result);

      yield response.outputAsString;

      notifyListeners();

      // If the session is aborted, remove the last message from memory and break the loop

      if (_session!.status == ChatSessionStatus.aborting) {
        _session!.status = ChatSessionStatus.idle;
        await _session!.memory.chatHistory.removeLast();

        _computePerformanceStatistics(result);

        notifyListeners();

        break;
      }
    }
  }

  /// Sends a message to the chat model and processes the response.
  ///
  /// The function first checks if a session is selected and creates a new one if not.
  /// If the text is empty, the function sends a system message and aborts generation.
  /// If no model is selected, the function sends a system message and aborts generation.
  /// The function then sets the session status to generating.
  /// It first add the user and the mepty model messages to the session.
  /// It then builds a chat chain and a prompt message to start generating the response.
  /// The response is streamed to offer real-time updates to the user.
  /// If the sessions is untitled, the function generates a title for it.
  ///
  /// Returns a [Future] that evaluates to `null`.
  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    if (!isSessionSelected) {
      newSession();
    }

    if (text.isEmpty) {
      addSystemMessage('Try to be more specific.');
      return;
    }

    if (!isModelSelected) {
      addSystemMessage('Please select a model.');
      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      }

      notifyListeners();

      addUserMessage(text, imageBytes);

      final prompt = _buildPrompt(text, imageBytes: imageBytes);

      await addModelMessage(_processChain(prompt), _modelName);

      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      notifyListeners();

      // If the session is untitled, generate a title

      if (_session!.title == 'Untitled') {
        final titleGeneratorPrompt = await rootBundle.loadString(
          'assets/prompts/sessions_title_generator.txt',
        );

        final prompt = PromptTemplate.fromTemplate(titleGeneratorPrompt);

        final chain = prompt | _chat | const StringOutputParser<ChatResult>();

        final response = await chain.invoke({'question': text});

        setSessionTitle(_session!.uuid, response.toString());
      }

      await GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      removeLastMessage();

      // Add a system message to inform the user about the error

      addSystemMessage('An error occurred while generating the response.');

      notifyListeners();

      await GetIt.instance<ChatSessionsDatabase>().updateSession(_session!);

      logger.e(e);
    }
  }

  /// Regenerates the message with the given UUID for the last user message.
  ///
  /// If the sessions is currently generating, the function returns without doing anything.
  /// NOTE: We don't need to check if the session is selected because the function is only called from the UI.
  /// The function first removes the last generated message from the session.
  /// Then it finds the last user message before the model message and uses its text to regenerate the response.
  /// This method does not regenerate the title of the session as it depends on the user's input.
  ///
  /// Returns a [Future] that evaluates to `null`.
  Future<void> regenerateMessage(String uuid) async {
    if (isGenerating) return;

    final modelMessageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[modelMessageIndex] is! ChatModelMessageWrapperV1) {
      return;
    }

    removeMessage(uuid);

    final userMessageIndex = _session!.messages.lastIndexWhere(
      (element) => element is ChatUserMessageWrapperV1,
      modelMessageIndex - 1,
    );

    final userMessage =
        _session!.messages[userMessageIndex] as ChatUserMessageWrapperV1;

    if (!isModelSelected) {
      addSystemMessage('Please select a model.');

      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      }

      notifyListeners();

      final prompt = _buildPrompt(
        userMessage.text,
        imageBytes: userMessage.imageBytes,
      );

      await addModelMessage(_processChain(prompt), _modelName);

      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        await WindowsTaskbar.resetThumbnailToolbar();
        await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      removeLastMessage();

      addSystemMessage('An error occurred while generating the response.');

      notifyListeners();

      logger.e(e);
    }
  }

  /// Regenerates the last message with the edited text and image bytes from the user.
  ///
  /// If the sessions is currently generating, the function returns without doing anything.
  /// NOTE: We don't need to check if the session is selected because the function is only called from the UI.
  /// The function first removes the last interaction from the session.
  /// Then it sends the edited message to the model for regeneration.
  ///
  /// Returns a [Future] that evaluates to `null`.
  Future<void> sendEditedMessage(
    String uuid,
    String text,
    Uint8List? imageBytes,
  ) async {
    if (isGenerating) return;

    final messageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[messageIndex] is! ChatUserMessageWrapperV1) {
      return;
    }

    removeMessage(uuid);

    await sendMessage(text, imageBytes: imageBytes);
  }

  /// Aborts the current session's generation process.
  ///
  /// If the session is not selected or currently generating, the function returns without doing anything.
  ///
  /// Returns `void`.
  void abortGeneration() {
    if (!isSessionSelected || !isGenerating) return;

    _session!.status = ChatSessionStatus.aborting;

    notifyListeners();
  }

  ///////////////////////////////////////////
  //      Session history management       //
  ///////////////////////////////////////////

  /// Loads the chat history of the current session.
  /// The function iterates over the messages of the session and adds them to the model's memory based on their sender.
  ///
  /// If the session is not selected or currently generating, the function returns without doing anything.
  ///
  /// Returns `void`.
  void loadSessionHistory() async {
    if (!isSessionSelected || isGenerating) return;

    for (final message in _session!.messages) {
      switch (message.sender) {
        case ChatMessageSender.system:
          continue;
        case ChatMessageSender.model:
          await _session!.memory.chatHistory.addAIChatMessage(
            message.text,
          );
          break;
        case ChatMessageSender.user:
          await _session!.memory.chatHistory.addHumanChatMessage(
            message.text,
          );
          break;
      }
    }

    notifyListeners();
  }

  /// Wipes the chat history of the current session.
  ///
  /// If the session is not selected or currently generating, the function returns without doing anything.
  ///
  /// Returns `void`.
  void clearSessionHistory() async {
    if (!isSessionSelected || isGenerating) return;

    await _session!.memory.chatHistory.clear();

    notifyListeners();
  }

  ///////////////////////////////////////////
  //          Settings management          //
  ///////////////////////////////////////////

  /// Sets the current model to the one with the given name and loads its settings
  ///
  /// The function first checks if the model is currently generating and returns without doing anything if it is.
  ///
  /// Returns a [Future] that evaluates to `void`.
  Future<void> setModel(String name) async {
    if (isGenerating) return;

    _modelName = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modelName', name);

    await updateChatOllamaOptions();

    notifyListeners();
  }

  /// Updates the global override settings for the current model.
  ///
  /// Returns a [Future] that evaluates to `void`.
  Future<void> updateChatOllamaOptions() async {
    _modelSettingsHandler = ModelSettingsHandler(modelName);

    await _modelSettingsHandler.preloadSettings();

    final settings = _modelSettingsHandler.activeModelSettings;

    int? numGpu;

    if (settings.numGpu == null) {
      numGpu = Platform.isMacOS ? 1 : null;
    } else if (settings.numGpu != 0) {
      numGpu = Platform.isMacOS ? settings.numGpu : null;
    } else {
      numGpu = settings.numGpu;
    }

    _chat = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: _modelName,
        numGpu: numGpu,
        keepAlive: settings.keepAlive,
        temperature: settings.temperature,
        concurrencyLimit: settings.concurrencyLimit ?? 1000,
        // NOTE: referer to the link https://github.com/davidmigloz/langchain_dart/issues/478
        f16KV: true,
        frequencyPenalty: settings.frequencyPenalty,
        logitsAll: settings.logitsAll,
        lowVram: settings.lowVram,
        mainGpu: settings.mainGpu,
        mirostat: settings.mirostat,
        mirostatEta: settings.mirostatEta,
        mirostatTau: settings.mirostatTau,
        numBatch: settings.numBatch,
        numCtx: settings.numCtx,
        numKeep: settings.numKeep,
        numPredict: settings.numPredict,
        numThread: settings.numThread,
        // NOTE: referer to the link https://github.com/davidmigloz/langchain_dart/issues/478
        numa: false,
        penalizeNewline: settings.penalizeNewline,
        presencePenalty: settings.presencePenalty,
        repeatLastN: settings.repeatLastN,
        repeatPenalty: settings.repeatPenalty,
        seed: settings.seed,
        stop: settings.stop,
        tfsZ: settings.tfsZ,
        topK: settings.topK,
        topP: settings.topP,
        typicalP: settings.typicalP,
        useMlock: settings.useMlock,
        useMmap: settings.useMmap,
        vocabOnly: settings.vocabOnly,
      ),
    );
  }

  /// Enables or disables the display of performance statistics for the current chat.
  ///
  /// Returns `void`.
  void enableStatistics(bool value) async {
    _showStatistics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showStatistics', value);
    notifyListeners();
  }

  ///////////////////////////////////////////
  //         Performance statistics        //
  ///////////////////////////////////////////

  /// Computes the performance statistics of the last message.
  ///
  /// The function extracts the metadata and usage statistics from the result and adds them to the last message.
  /// For metadata and usage statistics see [ChatResult.metadata] in langchain.dart.
  void _computePerformanceStatistics(ChatResult result) {
    lastMessage!.totalDuration +=
        result.metadata['total_duration'] as int? ?? 0;
    lastMessage!.loadDuration += result.metadata['load_duration'] as int? ?? 0;
    lastMessage!.promptEvalCount +=
        result.metadata['prompt_eval_count'] as int? ?? 0;
    lastMessage!.promptEvalDuration +=
        result.metadata['prompt_eval_duration'] as int? ?? 0;
    lastMessage!.evalCount += result.metadata['eval_count'] as int? ?? 0;
    lastMessage!.evalDuration += result.metadata['eval_duration'] as int? ?? 0;
    lastMessage!.promptTokens += result.usage.promptTokens ?? 0;
    lastMessage!.responseTokens += result.usage.responseTokens ?? 0;
    lastMessage!.totalTokens += result.usage.totalTokens ?? 0;
  }

  ///////////////////////////////////////////
  //          Getters and setters          //
  /// ///////////////////////////////////////

  String get modelName => _modelName;

  bool get isModelSelected => _modelName.isNotEmpty;

  bool get isChatShowStatistics => _showStatistics;

  bool get isMultimodalModel {
    final models = GetIt.instance<OllamaModelProvider>().models;

    if (!models.any((model) => model.name == _modelName)) return false;

    final modelFamilies = models
        .firstWhere(
          (model) => model.name == _modelName,
        )
        .details
        .families;

    if (modelFamilies == null) return false;

    final List<String> multiModalFamilies = [
      'clip',
      'blip',
      'flaming',
      'dall-e',
    ];

    return multiModalFamilies.any((family) => modelFamilies.contains(family));
  }

  ChatSessionWrapperV1? get session => _session;

  ChatSessionWrapperV1? get sessionByUuid {
    return _sessions.firstWhere(
      (element) => element.uuid == _session?.uuid,
    );
  }

  bool get isSessionSelected => _session != null;

  List<ChatMessageWrapperV1> get messages {
    return _session != null ? _session!.messages : [];
  }

  ChatMessageWrapperV1? get lastMessage => _session?.messages.last;

  ChatMessageWrapperV1? get lastUserMessage {
    return _session?.messages.lastWhere(
      (element) => element is ChatUserMessageWrapperV1,
    );
  }

  int get messageCount => _session != null ? _session!.messages.length : 0;

  List<ChatSessionWrapperV1> get sessions => _sessions;

  ChatSessionWrapperV1? get lastSession => _session;

  int get sessionCount => _sessions.length;

  bool get isGenerating {
    return _session != null
        ? _session!.status == ChatSessionStatus.generating
        : false;
  }
}
