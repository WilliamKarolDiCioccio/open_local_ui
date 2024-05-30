import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:open_local_ui/helpers/datetime.dart';
import 'package:open_local_ui/models/chat_message.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/utils/logger.dart';

class ChatProvider extends ChangeNotifier {
  late ChatOllama _model;
  String _modelName = '';

  bool _enableWebSearch = false;
  bool _enableDocsSearch = false;
  bool _enableOllamaGpu = true;

  ChatSessionWrapper? _session;
  final List<ChatSessionWrapper> _sessions = [];

  ChatProvider() {
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _enableWebSearch = prefs.getBool('enableWebSearch') ?? false;
    _enableDocsSearch = prefs.getBool('enableDocsSearch') ?? false;
    _enableOllamaGpu = prefs.getBool('enableOllamaGpu') ?? true;

    notifyListeners();
  }

  ChatSessionWrapper addSession(String title) {
    _sessions.add(ChatSessionWrapper(
      title,
      DateTimeHelpers.getFormattedDateTime(),
      const Uuid().v4(),
    ));

    notifyListeners();

    return _sessions.last;
  }

  void removeSession(String uuid) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    if (_sessions[index].status == ChatSessionStatus.generating) return;

    _sessions.removeAt(index);

    _session = null;

    notifyListeners();
  }

  ChatMessageWrapper addSystemMessage(String message) {
    _session!.messages.add(ChatSystemMessageWrapper(
      message,
      DateTimeHelpers.getFormattedDateTime(),
      const Uuid().v4(),
    ));

    notifyListeners();

    return _session!.messages.last;
  }

  ChatMessageWrapper addModelMessage(String message, String? senderName) {
    _session!.messages.add(ChatModelMessageWrapper(
      message,
      DateTimeHelpers.getFormattedDateTime(),
      const Uuid().v4(),
      senderName!,
    ));

    notifyListeners();

    return _session!.messages.last;
  }

  ChatMessageWrapper addUserMessage(String message, Uint8List? imageBytes) {
    _session!.messages.add(ChatUserMessageWrapper(
      message,
      DateTimeHelpers.getFormattedDateTime(),
      const Uuid().v4(),
      imageBytes: imageBytes,
    ));

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

    notifyListeners();
  }

  void removeLastMessage() async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    _session!.messages.removeLast();
    _session!.memory.chatHistory.removeLast();

    notifyListeners();
  }

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
      final session = addSession('');
      setSession(session.uuid);
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

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      removeLastMessage();

      addSystemMessage('An error occurred while generating the response.');

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

  void clearSessionHistory() async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    _session!.messages.clear();
    _session!.memory.chatHistory.clear();

    notifyListeners();
  }

  void setModel(String name, {double temperature = 0.8, bool useGpu = true}) {
    if (_session?.status == ChatSessionStatus.generating) {
      return;
    }

    _modelName = name;

    _model = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: name,
        temperature: temperature,
        numGpu: useGpu ? null : 0,
        format: OllamaResponseFormat.json,
      ),
    );

    notifyListeners();
  }

  void setSession(String uuid) {
    if (_session != null) {
      if (_session!.status == ChatSessionStatus.generating ||
          messageCount == 0) {
        return;
      }
    }

    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _session = _sessions[index];

    notifyListeners();
  }

  void abortGeneration() {
    if (_session == null && _session!.status != ChatSessionStatus.generating) {
      return;
    }

    _session!.status = ChatSessionStatus.aborting;

    notifyListeners();
  }

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

  void ollamaEnableGpu(bool value) async {
    _enableOllamaGpu = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enableOllamaGpu', value);

    setModel(_modelName, temperature: 0.8, useGpu: value);

    notifyListeners();
  }

  bool get isWebSearchEnabled => _enableWebSearch;

  bool get isDocsSearchEnabled => _enableDocsSearch;

  bool get isOllamaUsingGpu => _enableOllamaGpu;

  String get modelName => _modelName;

  bool get isModelSelected => _modelName.isNotEmpty;

  ChatSessionWrapper? get session => _session;

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
