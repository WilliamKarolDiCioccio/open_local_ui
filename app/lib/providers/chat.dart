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
import 'package:open_local_ui/database/sessions.dart';
import 'package:open_local_ui/models/chat_message.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // Langchain model
  ChatOllama _model;
  // Model settings
  String _modelName;
  bool _enableGPU;
  double _temperature;
  int _keepAliveTime;
  bool _enableWebSearch;
  bool _enableDocsSearch;
  bool _showStatistics;

  // Chat session
  ChatSessionWrapper? _session;
  final List<ChatSessionWrapper> _sessions = [];

  // Constructor and initialization

  ChatProvider()
      : _model = ChatOllama(),
        _modelName = '',
        _enableWebSearch = false,
        _enableDocsSearch = false,
        _enableGPU = true,
        _showStatistics = false,
        _temperature = 0.8,
        _keepAliveTime = 5 {
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final models = ModelProvider.getModelsStatic();
    final modelName = prefs.getString('modelName') ?? '';

    if (models.any((model) => model.name == modelName)) {
      _modelName = modelName;
    } else {
      _modelName = models.first.name;
    }

    _enableWebSearch = prefs.getBool('enableWebSearch') ?? false;
    _enableDocsSearch = prefs.getBool('enableDocsSearch') ?? false;
    _enableGPU = prefs.getBool('enableGPU') ?? true;
    _temperature = prefs.getDouble('temperature') ?? 0.8;
    _keepAliveTime = prefs.getInt('keepAliveTime') ?? 5;
    _showStatistics = prefs.getBool('showStatistics') ?? false;

    _updateModelOptions();

    final docsDir = await getApplicationDocumentsDirectory();

    final loadedSessions = await Isolate.run(
      () async {
        Hive.init('${docsDir.path}/OpenLocalUI/saved_data');

        return await SessionsDatabase.loadSessions();
      },
    );

    _sessions.addAll(loadedSessions);

    notifyListeners();
  }

  // Sessions management

  ChatSessionWrapper addSession(String title) {
    _sessions.add(ChatSessionWrapper(
      DateTime.now(),
      const Uuid().v4(),
      [],
    ));

    SessionsDatabase.saveSession(_sessions.last);

    notifyListeners();

    return _sessions.last;
  }

  void newSession() {
    final session = addSession('');
    setSession(session.uuid);
    notifyListeners();
  }

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

  void removeSession(String uuid) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    if (_sessions[index].status == ChatSessionStatus.generating) return;

    _sessions.removeAt(index);

    if (isSessionSelected && _session!.uuid == uuid) {
      () async {
        doWhenWindowReady(() async {
          appWindow.title = 'OpenLocalUI';
        });
      }();
    }

    _session = null;

    SessionsDatabase.deleteSession(uuid);

    notifyListeners();
  }

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

    SessionsDatabase.updateSession(_sessions[index]);

    notifyListeners();
  }

  // Messages management

  ChatSystemMessageWrapper addSystemMessage(String message) {
    final chatMessage = ChatSystemMessageWrapper(
      message,
      DateTime.now(),
      const Uuid().v4(),
    );

    if (isSessionSelected) return chatMessage;

    _session!.messages.add(chatMessage);

    SessionsDatabase.updateSession(_session!);

    notifyListeners();

    return _session!.messages.last as ChatSystemMessageWrapper;
  }

  ChatModelMessageWrapper addModelMessage(String message, String? senderName) {
    final chatMessage = ChatModelMessageWrapper(
      message,
      DateTime.now(),
      const Uuid().v4(),
      senderName!,
    );

    if (!isSessionSelected) return chatMessage;

    _session!.messages.add(chatMessage);

    SessionsDatabase.updateSession(_session!);

    notifyListeners();

    return _session!.messages.last as ChatModelMessageWrapper;
  }

  ChatMessageWrapper addUserMessage(String message, Uint8List? imageBytes) {
    final chatMessage = ChatUserMessageWrapper(
      message,
      DateTime.now(),
      const Uuid().v4(),
      imageBytes: imageBytes,
    );

    if (_session == null) return chatMessage;

    _session!.messages.add(chatMessage);

    SessionsDatabase.updateSession(_session!);

    notifyListeners();

    return _session!.messages.last;
  }

  void removeMessage(String uuid) async {
    if (!isSessionSelected || isGenerating) return;

    final index = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    _session!.messages.removeAt(index);

    _session!.memory.chatHistory.removeLast();

    SessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  void removeFromMessage(String uuid) async {
    if (!isSessionSelected || isGenerating) return;

    final index = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    _session!.messages.removeRange(index, messageCount);

    for (var i = 0; i < messageCount - index; ++i) {
      _session!.memory.chatHistory.removeLast();
    }

    SessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  void removeLastMessage() async {
    if (!isSessionSelected || isGenerating || messageCount == 0) {
      return;
    }

    _session!.messages.removeLast();
    _session!.memory.chatHistory.removeLast();

    SessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  // Chat logic

  Future<RunnableSequence> _buildChain() async {
    final defaultPrompt = await rootBundle.loadString(
      'assets/prompts/default.txt',
    );

    final promptTemplate = ChatPromptTemplate.fromPromptMessages([
      ChatMessagePromptTemplate.system(defaultPrompt),
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
        _model;

    return chain;
  }

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

  Future sendMessage(String text, {Uint8List? imageBytes}) async {
    if (!isSessionSelected) {
      newSession();
    }

    if (text.isEmpty) {
      addSystemMessage('Try to be more specific.');

      return;
    } else if (!isModelSelected) {
      addSystemMessage('Please select a model.');

      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      notifyListeners();

      addUserMessage(text, imageBytes);

      _session!.memory.chatHistory.addHumanChatMessage(
        _session!.messages.last.text,
      );

      final chain = await _buildChain();

      final prompt = _buildPrompt(text, imageBytes: imageBytes);

      addModelMessage('', _modelName);

      await for (final response in chain.stream([prompt])) {
        ChatResult result = response as ChatResult;
        if (_session!.status == ChatSessionStatus.aborting) {
          _session!.status = ChatSessionStatus.idle;
          _session!.memory.chatHistory.removeLast();
          break;
        }

        final lastMessage = _session!.messages.last;
        lastMessage.text += result.outputAsString;

        // Update metadata and usage.
        lastMessage.totalDuration +=
            result.metadata['total_duration'] as int? ?? 0;
        lastMessage.loadDuration +=
            result.metadata['load_duration'] as int? ?? 0;
        lastMessage.promptEvalCount +=
            result.metadata['prompt_eval_count'] as int? ?? 0;
        lastMessage.promptEvalDuration +=
            result.metadata['prompt_eval_duration'] as int? ?? 0;
        lastMessage.evalCount += result.metadata['eval_count'] as int? ?? 0;
        lastMessage.evalDuration +=
            result.metadata['eval_duration'] as int? ?? 0;
        lastMessage.promptTokens += result.usage.promptTokens ?? 0;
        lastMessage.responseTokens += result.usage.responseTokens ?? 0;
        lastMessage.totalTokens += result.usage.totalTokens ?? 0;

        notifyListeners();
      }

      _session!.memory.chatHistory.addAIChatMessage(
        _session!.messages.last.text,
      );

      _session!.status = ChatSessionStatus.idle;

      notifyListeners();

      if (_session!.title == 'Untitled') {
        final titleGeneratorPrompt = await rootBundle.loadString(
          'assets/prompts/title_generator.txt',
        );

        final prompt = PromptTemplate.fromTemplate(titleGeneratorPrompt);

        final chain = prompt | _model | const StringOutputParser<ChatResult>();

        final response = await chain.invoke({'question': text});

        setSessionTitle(_session!.uuid, response.toString());
      }

      SessionsDatabase.updateSession(_session!);

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      removeLastMessage();

      addSystemMessage('An error occurred while generating the response.');

      SessionsDatabase.updateSession(_session!);

      logger.e(e);
    }
  }

  void regenerateMessage(String uuid) async {
    if (!isSessionSelected || isGenerating) return;

    final modelMessageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[modelMessageIndex] is! ChatModelMessageWrapper) {
      return;
    }

    removeFromMessage(uuid);

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

      notifyListeners();

      final chain = await _buildChain();

      final prompt = _buildPrompt(
        userMessage.text,
        imageBytes: userMessage.imageBytes,
      );

      addModelMessage('', _modelName);

      await for (final response in chain.stream([prompt])) {
        if (_session!.status == ChatSessionStatus.aborting) {
          _session!.status = ChatSessionStatus.idle;

          _session!.memory.chatHistory.removeLast();

          break;
        }

        _session!.messages.last.text += response.toString();

        notifyListeners();
      }

      _session!.memory.chatHistory.addAIChatMessage(
        _session!.messages.last.text,
      );

      _session!.status = ChatSessionStatus.idle;

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      removeLastMessage();

      addSystemMessage('An error occurred while generating the response.');

      logger.e(e);
    }
  }

  void sendEditedMessage(
    String uuid,
    String text,
    Uint8List? imageBytes,
  ) async {
    if (!isSessionSelected || isGenerating) return;

    final messageIndex = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    if (_session!.messages[messageIndex] is! ChatUserMessageWrapper) {
      return;
    }

    removeFromMessage(uuid);

    sendMessage(text, imageBytes: imageBytes);
  }

  void abortGeneration() {
    if (!isSessionSelected || !isGenerating) return;

    _session!.status = ChatSessionStatus.aborting;

    notifyListeners();
  }

  // Session history management

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

  void clearSessionHistory() async {
    if (!isSessionSelected || isGenerating) return;

    _session!.memory.chatHistory.clear();

    notifyListeners();
  }

  // Model configuration

  void _updateModelOptions() {
    int? numGPU;

    if (_enableGPU) {
      numGPU = Platform.isMacOS ? 1 : null;
    } else {
      numGPU = 0;
    }

    final modelOptions = ChatOllamaOptions(
      model: _modelName,
      keepAlive: _keepAliveTime,
      temperature: _temperature,
      numGpu: numGPU,
      format: OllamaResponseFormat.json,
    );

    _model = ChatOllama(defaultOptions: modelOptions);
  }

  void setModel(String name) async {
    if (isGenerating) return;

    _modelName = name;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('modelName', name);

    _updateModelOptions();

    notifyListeners();
  }

  void setTemperature(double value) async {
    if (isGenerating) return;

    _temperature = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('temperature', value);

    _updateModelOptions();

    notifyListeners();
  }

  void setKeepAliveTime(int value) async {
    if (isGenerating) return;

    _keepAliveTime = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('keepAliveTime', value.toInt());

    _updateModelOptions();

    notifyListeners();
  }

  void enableGPU(bool value) async {
    if (isGenerating) return;

    _enableGPU = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableGPU', value);

    _updateModelOptions();

    notifyListeners();
  }

  void enableStatistics(bool value) async {
    _showStatistics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showStatistics', value);
    notifyListeners();
  }

  void enableWebSearch(bool value) async {
    if (isGenerating) return;

    _enableWebSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableWebSearch', value);

    _updateModelOptions();

    notifyListeners();
  }

  void enableDocsSearch(bool value) async {
    if (isGenerating) return;

    _enableDocsSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableDocsSearch', value);

    _updateModelOptions();

    notifyListeners();
  }

  // Getters

  String get modelName => _modelName;

  bool get isModelSelected => _modelName.isNotEmpty;

  double get temperature => _temperature;

  double get keepAliveTime => _keepAliveTime.toDouble();

  bool get isOllamaUsingGpu => _enableGPU;

  bool get isChatShowStatistics => _showStatistics;

  bool get isWebSearchEnabled => _enableWebSearch;

  bool get isDocsSearchEnabled => _enableDocsSearch;

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
