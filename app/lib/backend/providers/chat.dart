import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/backend/databases/chat_sessions.dart';
import 'package:open_local_ui/backend/models/chat_message.dart';
import 'package:open_local_ui/backend/models/chat_session.dart';
import 'package:open_local_ui/backend/models/model.dart';
import 'package:open_local_ui/backend/providers/model.dart';
import 'package:open_local_ui/backend/providers/model_settings.dart';
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
  ChatOllama _chat;

  // Global override settings
  String _modelName;
  bool _enableGPU;
  double _temperature;
  int _keepAliveTime;
  bool _enableWebSearch;
  bool _enableDocsSearch;
  bool _showStatistics;

  // Model specific settings
  late ModelSettings _modelSettings;

  // Chat session
  ChatSessionWrapper? _session;
  final List<ChatSessionWrapper> _sessions = [];

  // Constructor and initialization

  ChatProvider()
      : _chat = ChatOllama(),
        _modelName = '',
        _enableWebSearch = false,
        _enableDocsSearch = false,
        _enableGPU = true,
        _showStatistics = false,
        _temperature = 0.8,
        _keepAliveTime = 5 {
    loadSettings();
  }

  /// Called when the provider is initialized to load model specific, global override settings and chat sessions.
  ///
  /// Global override settings are stored using the [SharedPreferences] plugin.
  /// Model specific settings are stored in the app's data directory as JSON files (see [ModelSettingsProvider]).
  /// Chat sessions are stored in the app's data directory using the Hive database (see [ChatSessionsDatabase]).
  ///
  /// Returns a [Future] that evaluates to `void`.
  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final models = ModelProvider.getModelsStatic();
    final modelName = prefs.getString('modelName') ?? '';

    if (models.any((model) => model.name == modelName)) {
      _modelName = modelName;
    } else {
      if (models.isNotEmpty) _modelName = models.first.name;
    }

    _enableWebSearch = prefs.getBool('enableWebSearch') ?? false;
    _enableDocsSearch = prefs.getBool('enableDocsSearch') ?? false;
    _enableGPU = prefs.getBool('enableGPU') ?? true;
    _temperature = prefs.getDouble('temperature') ?? 0.8;
    _keepAliveTime = prefs.getInt('keepAliveTime') ?? 5;
    _showStatistics = prefs.getBool('showStatistics') ?? false;

    _modelSettings = await ModelSettingsProvider.loadStatic(modelName);

    _updateModelOptions();

    final docsDir = await getApplicationDocumentsDirectory();
    final dataDir = await getApplicationSupportDirectory();

    _sessions.addAll(
      await Isolate.run(
        () async {
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

          Hive.init('${dataDir.path}/sessions');
          return await ChatSessionsDatabase.loadSessions();
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
  /// Returns the newly created [ChatSessionWrapper].
  ChatSessionWrapper addSession(String title) {
    _sessions.add(ChatSessionWrapper(
      DateTime.now(),
      const Uuid().v4(),
      [],
    ));

    ChatSessionsDatabase.saveSession(_sessions.last);

    notifyListeners();

    return _sessions.last;
  }

  /// Creates a new chat session and sets it as the current session.
  ///
  /// Returns `void`.
  void newSession() {
    final session = addSession('');
    setSession(session.uuid);
    notifyListeners();
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
      if (message is ChatModelMessageWrapper) {
        final models = ModelProvider.getModelsStatic();

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

    ChatSessionsDatabase.deleteSession(uuid);

    notifyListeners();
  }

  /// Removes all sessions from the list of sessions and deletes them from the database.
  ///
  /// Under the hood, the function iterates over the list of sessions and removes each session one by one.
  /// This means it follows the same logic as [removeSession] inherits its constraints.
  ///
  /// Returns `void`.
  void clearSessions() {
    List<String> uuids = [];

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

    ChatSessionsDatabase.updateSession(_sessions[index]);

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
  ChatSystemMessageWrapper addSystemMessage(String message) {
    final chatMessage = ChatSystemMessageWrapper(
      message,
      DateTime.now(),
      const Uuid().v4(),
    );

    if (!isSessionSelected) return chatMessage;

    _session!.messages.add(chatMessage);

    // System messages shouldn't be added to the memory

    ChatSessionsDatabase.updateSession(_session!);

    notifyListeners();

    return _session!.messages.last as ChatSystemMessageWrapper;
  }

  /// Adds a chat message of type model to the current session and to the model's memory and updates the session in the database.
  ///
  /// If the session is not selected, the function returns the newly created [ChatModelMessageWrapper] without adding it to the memory or the database.
  ///
  /// Returns the newly created [ChatModelMessageWrapper].
  StreamSubscription<String> addModelMessage(
    Stream<String> messageStream,
    String senderName,
  ) {
    final StringBuffer messageBuffer = StringBuffer();
    final DateTime timestamp = DateTime.now();
    final String messageId = const Uuid().v4();

    final chatMessage = ChatModelMessageWrapper(
      '',
      timestamp,
      messageId,
      senderName,
    );

    _session!.messages.add(chatMessage);

    final StreamSubscription<String> subscription = messageStream.listen(
      (message) {
        messageBuffer.write(message);

        _session!.messages.last.text = messageBuffer.toString();
      },
      onDone: () {
        if (isSessionSelected) {
          _session!.memory.chatHistory.addAIChatMessage(
            messageBuffer.toString(),
          );
          ChatSessionsDatabase.updateSession(_session!);
          notifyListeners();
        }
      },
    );

    return subscription;
  }

  /// Adds a chat message of type user to the current session and to the model's memory and updates the session in the database.
  ///
  /// If the session is not selected, the function returns the newly created [ChatUserMessageWrapper] without adding it to the memory or the database.
  ///
  /// User messages have optional [imageBytes] attached to them for use in multimodal models.
  ///
  /// Returns the newly created [ChatUserMessageWrapper].
  ChatMessageWrapper addUserMessage(String message, Uint8List? imageBytes) {
    final chatMessage = ChatUserMessageWrapper(
      message,
      DateTime.now(),
      const Uuid().v4(),
      imageBytes: imageBytes,
    );

    if (_session == null) return chatMessage;

    _session!.messages.add(chatMessage);
    _session!.memory.chatHistory.addHumanChatMessage(message);

    ChatSessionsDatabase.updateSession(_session!);

    notifyListeners();

    return _session!.messages.last;
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
      _session!.memory.chatHistory.removeLast();
    }

    ChatSessionsDatabase.updateSession(_session!);

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
    _session!.memory.chatHistory.removeLast();

    ChatSessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  void clearMessages() async {
    if (!isSessionSelected || isGenerating) return;

    _session!.messages.clear();
    _session!.memory.chatHistory.clear();

    ChatSessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  ///////////////////////////////////////////
  //          Chat logic management        //
  ///////////////////////////////////////////

  /// Builds a chat chain that processes the user's input and generates a response.
  Future<RunnableSequence> _buildChain() async {
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
    if (_modelSettings.systemPrompt != null &&
        _modelSettings.systemPrompt!.isNotEmpty) {
      return _modelSettings.systemPrompt!;
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
    final chain = await _buildChain();

    await for (final response in chain.stream([prompt])) {
      final result = response as ChatResult;

      _computePerformanceStatistics(result);

      yield response.outputAsString;

      notifyListeners();

      // If the session is aborted, remove the last message from memory and break the loop

      if (_session!.status == ChatSessionStatus.aborting) {
        _session!.status = ChatSessionStatus.idle;
        _session!.memory.chatHistory.removeLast();

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
  Future sendMessage(String text, {Uint8List? imageBytes}) async {
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
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      }

      notifyListeners();

      addUserMessage(text, imageBytes);

      final prompt = _buildPrompt(text, imageBytes: imageBytes);

      addModelMessage(_processChain(prompt), _modelName);

      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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

      ChatSessionsDatabase.updateSession(_session!);

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      removeLastMessage();

      // Add a system message to inform the user about the error

      addSystemMessage('An error occurred while generating the response.');

      notifyListeners();

      ChatSessionsDatabase.updateSession(_session!);

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
  Future regenerateMessage(String uuid) async {
    if (isGenerating) return;

    final modelMessageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[modelMessageIndex] is! ChatModelMessageWrapper) {
      return;
    }

    removeMessage(uuid);

    final userMessageIndex = _session!.messages.lastIndexWhere(
      (element) => element is ChatUserMessageWrapper,
      modelMessageIndex - 1,
    );

    final userMessage =
        _session!.messages[userMessageIndex] as ChatUserMessageWrapper;

    if (!isModelSelected) {
      addSystemMessage('Please select a model.');

      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      if (Platform.isWindows) {
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      }

      notifyListeners();

      final prompt = _buildPrompt(
        userMessage.text,
        imageBytes: userMessage.imageBytes,
      );

      addModelMessage(_processChain(prompt), _modelName);

      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      if (Platform.isWindows) {
        WindowsTaskbar.resetThumbnailToolbar();
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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
  Future sendEditedMessage(
    String uuid,
    String text,
    Uint8List? imageBytes,
  ) async {
    if (isGenerating) return;

    final messageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[messageIndex] is! ChatUserMessageWrapper) {
      return;
    }

    removeMessage(uuid);

    sendMessage(text, imageBytes: imageBytes);
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
          _session!.memory.chatHistory.addAIChatMessage(
            message.text,
          );
          break;
        case ChatMessageSender.user:
          _session!.memory.chatHistory.addHumanChatMessage(
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

    _session!.memory.chatHistory.clear();

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
  Future setModel(String name) async {
    if (isGenerating) return;

    _modelName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modelName', name);
    _modelSettings = await ModelSettingsProvider.loadStatic(modelName);
    _updateModelOptions();

    notifyListeners();
  }

  /// Updates the global override settings for the current model.
  ///
  /// Returns `void`.
  void _updateModelOptions() {
    int? numGPU;

    if (_enableGPU) {
      numGPU = Platform.isMacOS ? 1 : null;
    } else {
      numGPU = 0;
    }

    final modelOptions = ChatOllamaOptions(
      model: _modelName,
      numGpu: numGPU,
      keepAlive: _modelSettings.keepAlive ?? _keepAliveTime,
      temperature: _modelSettings.temperature ?? _temperature,
      concurrencyLimit: _modelSettings.concurrencyLimit ?? 1000,
      // NOTE: referer to the link https://github.com/davidmigloz/langchain_dart/issues/478
      f16KV: true,
      frequencyPenalty: _modelSettings.frequencyPenalty,
      logitsAll: _modelSettings.logitsAll,
      lowVram: _modelSettings.lowVram,
      mainGpu: _modelSettings.mainGpu,
      mirostat: _modelSettings.mirostat,
      mirostatEta: _modelSettings.mirostatEta,
      mirostatTau: _modelSettings.mirostatTau,
      numBatch: _modelSettings.numBatch,
      numCtx: _modelSettings.numCtx,
      numKeep: _modelSettings.numKeep,
      numPredict: _modelSettings.numPredict,
      numThread: _modelSettings.numThread,
      // NOTE: referer to the link https://github.com/davidmigloz/langchain_dart/issues/478
      numa: false,
      penalizeNewline: _modelSettings.penalizeNewline,
      presencePenalty: _modelSettings.presencePenalty,
      repeatLastN: _modelSettings.repeatLastN,
      repeatPenalty: _modelSettings.repeatPenalty,
      seed: _modelSettings.seed,
      stop: _modelSettings.stop,
      tfsZ: _modelSettings.tfsZ,
      topK: _modelSettings.topK,
      topP: _modelSettings.topP,
      typicalP: _modelSettings.typicalP,
      useMlock: _modelSettings.useMlock,
      useMmap: _modelSettings.useMmap,
      vocabOnly: _modelSettings.vocabOnly,
    );

    _chat = ChatOllama(defaultOptions: modelOptions);
  }

  /// Global override for setting the temperature.
  ///
  /// Returns `void`.
  void setTemperature(double value) async {
    if (isGenerating) return;

    _temperature = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('temperature', value);

    _updateModelOptions();

    notifyListeners();
  }

  /// Global override for setting the keep alive time.
  ///
  /// Returns `void`.
  void setKeepAliveTime(int value) async {
    if (isGenerating) return;

    _keepAliveTime = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('keepAliveTime', value.toInt());

    _updateModelOptions();

    notifyListeners();
  }

  /// Global override for enabling GPU usage.
  ///
  /// Returns `void`.
  void enableGPU(bool value) async {
    if (isGenerating) return;

    _enableGPU = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableGPU', value);

    _updateModelOptions();

    notifyListeners();
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

  /// Global override for enabling web search.
  ///
  /// Returns `void`.
  void enableWebSearch(bool value) async {
    if (isGenerating) return;

    _enableWebSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableWebSearch', value);

    _updateModelOptions();

    notifyListeners();
  }

  /// Global override for enabling docs search.
  ///
  /// Returns `void`.
  void enableDocsSearch(bool value) async {
    if (isGenerating) return;

    _enableDocsSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableDocsSearch', value);

    _updateModelOptions();

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

  double get temperature => _temperature;

  double get keepAliveTime => _keepAliveTime.toDouble();

  bool get isOllamaUsingGpu => _enableGPU;

  bool get isChatShowStatistics => _showStatistics;

  bool get isWebSearchEnabled => _enableWebSearch;
  bool get isWebSearchEnabledForModel =>
      _modelSettings.enableWebSearch ?? _enableWebSearch;

  bool get isDocsSearchEnabled => _enableDocsSearch;
  bool get isDocsSearchEnabledForModel =>
      _modelSettings.enableDocsSearch ?? _enableDocsSearch;

  bool get isMultimodalModel {
    final models = ModelProvider.getModelsStatic();

    if (!models.any((model) => model.name == _modelName)) return false;

    final modelFamilies = models
        .firstWhere(
          (model) => model.name == _modelName,
        )
        .details
        .families;

    if (modelFamilies == null) return false;

    List<String> multiModalFamilies = ['clip', 'blip', 'flaming', 'dall-e'];

    return multiModalFamilies.any((family) => modelFamilies.contains(family));
  }

  ChatSessionWrapper? get session => _session;

  ChatSessionWrapper? get sessionByUuid {
    return _sessions.firstWhere(
      (element) => element.uuid == _session?.uuid,
    );
  }

  bool get isSessionSelected => _session != null;

  List<ChatMessageWrapper> get messages {
    return _session != null ? _session!.messages : [];
  }

  ChatMessageWrapper? get lastMessage => _session?.messages.last;

  ChatMessageWrapper? get lastUserMessage {
    return _session?.messages.lastWhere(
      (element) => element is ChatUserMessageWrapper,
    );
  }

  int get messageCount => _session != null ? _session!.messages.length : 0;

  List<ChatSessionWrapper> get sessions => _sessions;

  ChatSessionWrapper? get lastSession => _session;

  int get sessionCount => _sessions.length;

  bool get isGenerating {
    return _session != null
        ? _session!.status == ChatSessionStatus.generating
        : false;
  }
}
