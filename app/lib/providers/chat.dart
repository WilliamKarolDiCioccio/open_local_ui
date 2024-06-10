import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  late bool _enableWebSearch;
  late bool _enableDocsSearch;
  late bool _enableAutoscroll;
  late bool _enableGPU;
  late ChatOllama _model;
  late String _modelName;

  ChatSessionWrapper? _session;
  final List<ChatSessionWrapper> _sessions = [];

  // Constructor and initialization

  ChatProvider()
      : _enableWebSearch = false,
        _enableDocsSearch = false,
        _enableAutoscroll = true,
        _enableGPU = true,
        _model = ChatOllama(),
        _modelName = '' {
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _enableWebSearch = prefs.getBool('enableWebSearch') ?? false;
    _enableDocsSearch = prefs.getBool('enableDocsSearch') ?? false;
    _enableAutoscroll = prefs.getBool('enableAutoscroll') ?? true;
    _enableGPU = prefs.getBool('enableGPU') ?? true;

    final models = ModelProvider.getModelsStatic();
    final modelName = prefs.getString('modelName') ?? '';

    if (models.any((model) => model.name == modelName)) {
      setModel(modelName);
    } else {
      setModel(models.first.name);
    }

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
      title,
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
    if (_session != null) {
      if (_session!.status == ChatSessionStatus.generating) {
        return;
      }
    }

    clearSessionHistory();

    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _session = _sessions[index];

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

    _session = null;

    SessionsDatabase.deleteSession(uuid);

    notifyListeners();
  }

  void setSessionTitle(String uuid, String title) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _sessions[index].title = title;

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

    if (_session == null) return chatMessage;

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

    if (_session == null) return chatMessage;

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
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    final index = _session!.messages.indexWhere(
      (element) => element.uuid == uuid,
    );

    _session!.messages.removeAt(index);

    _session!.memory.chatHistory.removeLast();

    SessionsDatabase.updateSession(_session!);

    notifyListeners();
  }

  void removeFromMessage(String uuid) async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

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
    if (_session == null ||
        _session!.status == ChatSessionStatus.generating ||
        messageCount == 0) {
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
        _model |
        const StringOutputParser<ChatResult>();

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
    if (_session == null) {
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

      if (_session!.title.isEmpty) {
        final titleGeneratorPrompt = await rootBundle.loadString(
          'assets/prompts/title_generator.txt',
        );

        final prompt = PromptTemplate.fromTemplate(titleGeneratorPrompt);

        final chain = prompt | _model | const StringOutputParser<ChatResult>();

        final response = await chain.invoke({'question': text});

        _session!.title = response.toString();
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
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

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
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

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
    if (_session == null && _session!.status != ChatSessionStatus.generating) {
      return;
    }

    _session!.status = ChatSessionStatus.aborting;

    notifyListeners();
  }

  // Session history management

  void loadSessionHistory() async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

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
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    _session!.memory.chatHistory.clear();

    notifyListeners();
  }

  // Model management

  void setModel(String name) async {
    if (_session != null) {
      if (_session?.status == ChatSessionStatus.generating) {
        return;
      }
    }

    _modelName = name;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('modelName', name);

    late int? numGPU;

    if (_enableGPU) {
      if (Platform.isMacOS) {
        numGPU = 1;
      } else {
        numGPU = null;
      }
    }

    _model = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: name,
        keepAlive: 5,
        temperature: 0.8,
        numGpu: numGPU,
        format: OllamaResponseFormat.json,
      ),
    );

    notifyListeners();
  }

  // Chat configuration

  void enableWebSearch(bool value) async {
    _enableWebSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableWebSearch', value);

    notifyListeners();
  }

  void enableDocsSearch(bool value) async {
    _enableDocsSearch = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableDocsSearch', value);

    notifyListeners();
  }

  void enableAutoscroll(bool value) async {
    _enableAutoscroll = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableAutoscroll', value);

    notifyListeners();
  }

  void enableGPU(bool value) async {
    _enableGPU = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableGPU', value);

    setModel(_modelName);

    notifyListeners();
  }

  bool get isWebSearchEnabled => _enableWebSearch;

  bool get isDocsSearchEnabled => _enableDocsSearch;

  bool get isAutoscrollEnabled => _enableAutoscroll;

  bool get isOllamaUsingGpu => _enableGPU;

  String get modelName => _modelName;

  bool get isModelSelected => _modelName.isNotEmpty;

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
