import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:uuid/uuid.dart';

import 'package:open_local_ui/models/chat_message.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/utils/logger.dart';

class ChatProvider extends ChangeNotifier {
  late ChatOllama _model;
  String _modelName = '';

  bool _webSearch = false;
  bool _docsSearch = true;

  ChatSessionWrapper? _session;
  final List<ChatSessionWrapper> _sessions = [];

  ChatSessionWrapper addSession(String title) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final uuid = const Uuid().v4();

    _sessions.add(ChatSessionWrapper(
      title,
      formattedDateTime,
      uuid,
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

  ChatMessageWrapper addMessage(
    String message,
    ChatMessageSender sender, {
    Uint8List? imageBytes,
    String? senderName,
  }) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final uuid = const Uuid().v4();

    _session!.messages.add(ChatMessageWrapper(
      message,
      formattedDateTime,
      uuid,
      sender,
      senderName: senderName,
      imageBytes: imageBytes,
    ));

    notifyListeners();

    return _session!.messages.last;
  }

  void removeMessage(String uuid) async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    final index =
        _session!.messages.indexWhere((element) => element.uuid == uuid);
    _session!.messages.removeAt(index);

    _session!.memory.chatHistory.removeLast();

    notifyListeners();
  }

  void removeFromMessage(String uuid) async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    final index =
        _session!.messages.indexWhere((element) => element.uuid == uuid);
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
    final defaultPrompt = await rootBundle.loadString('assets/prompts/default.txt');

    final promptTemplate = ChatPromptTemplate.fromPromptMessages( [
      ChatMessagePromptTemplate.system(defaultPrompt),
      const MessagesPlaceholder(variableName: 'history'),
      const MessagesPlaceholder(variableName: 'input'),
    ]);

    final chain = Runnable.fromMap({
          'input': Runnable.passthrough(),
          'history': Runnable.fromFunction(
            (final _, final __) async {
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
    if (text.isEmpty || isGenerating) {
      return;
    } else if (_session == null) {
      final session = addSession('');
      setSession(session.uuid);
    } else if (!isModelSelected) {
      addMessage(
        'Please select a model.',
        ChatMessageSender.system,
      );

      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      notifyListeners();

      addMessage(
        text,
        ChatMessageSender.user,
        imageBytes: imageBytes,
      );

      _session!.memory.chatHistory
          .addHumanChatMessage(_session!.messages.last.text);

      final chain = await _buildChain();

      final prompt = _buildPrompt(text, imageBytes: imageBytes);

      addMessage(
        '',
        ChatMessageSender.model,
        senderName: _modelName,
      );

      await for (final response in chain.stream([prompt])) {
        if (_session!.status == ChatSessionStatus.aborting) {
          _session!.status = ChatSessionStatus.idle;

          _session!.memory.chatHistory.removeLast();

          break;
        }

        _session!.messages.last.text += response.toString();

        notifyListeners();
      }

      _session!.memory.chatHistory
          .addAIChatMessage(_session!.messages.last.text);

      _session!.status = ChatSessionStatus.idle;

      notifyListeners();

      if (_session!.title.isEmpty) {
        final prompt = PromptTemplate.fromTemplate(
          'Write a three to six words long title for the question "{question}", no more than 64 characters.',
        );

        final chain = prompt | _model | const StringOutputParser<ChatResult>();

        final response = await chain.invoke({'question': text});

        _session!.title = response.toString();
      }

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      removeLastMessage();

      addMessage(
        'An error occurred while generating the response.',
        ChatMessageSender.system,
      );

      logger.e(e);
    }
  }

  void regenerateMessage(String uuid) async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    Uint8List? imageBytes = lastMessage!.imageBytes;

    removeFromMessage(uuid);

    if (!isModelSelected) {
      addMessage(
        'Please select a model.',
        ChatMessageSender.system,
      );

      return;
    }

    try {
      _session!.status = ChatSessionStatus.generating;

      notifyListeners();

      final chain = await _buildChain();

      final prompt = _buildPrompt(lastMessage!.text, imageBytes: imageBytes);

      addMessage(
        '',
        ChatMessageSender.model,
        senderName: _modelName,
      );

      await for (final response in chain.stream([prompt])) {
        if (_session!.status == ChatSessionStatus.aborting) {
          _session!.status = ChatSessionStatus.idle;

          _session!.memory.chatHistory.removeLast();

          break;
        }

        _session!.messages.last.text += response.toString();

        notifyListeners();
      }

      _session!.memory.chatHistory
          .addAIChatMessage(_session!.messages.last.text);

      _session!.status = ChatSessionStatus.idle;

      notifyListeners();
    } catch (e) {
      _session!.status = ChatSessionStatus.idle;

      removeLastMessage();

      addMessage(
        'An error occurred while generating the response.',
        ChatMessageSender.system,
      );

      logger.e(e);
    }
  }

  void resendMessage(String uuid, String text) async {
    if (_session == null || _session!.status == ChatSessionStatus.generating) {
      return;
    }

    Uint8List? imageBytes = lastMessage!.imageBytes;

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

  void setModel(String name, {double temperature = 0.8}) {
    _modelName = name;

    _model = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: name,
        temperature: temperature,
        format: OllamaResponseFormat.json,
      ),
    );

    notifyListeners();
  }

  void setSession(String uuid) {
    final index = _sessions.indexWhere((element) => element.uuid == uuid);

    _session = _sessions[index];

    notifyListeners();
  }

  void abortGeneration() {
    if (_session!.status == ChatSessionStatus.generating && _session != null) {
      _session!.status = ChatSessionStatus.aborting;

      notifyListeners();
    }
  }

  set webSearch(bool value) {
    _webSearch = value;

    notifyListeners();
  }

  set docsSearch(bool value) {
    _docsSearch = value;

    notifyListeners();
  }

  bool get isWebSearchEnabled => _webSearch;

  bool get isDocsSearchEnabled => _docsSearch;

  String get modelName => _modelName;

  bool get isModelSelected => _modelName.isNotEmpty;

  ChatSessionWrapper? get session => _session;

  bool get isSessionSelected => _session != null;

  List<ChatMessageWrapper> get messages =>
      _session != null ? _session!.messages : [];

  ChatMessageWrapper? get lastMessage => _session?.messages.last;

  int get messageCount => _session != null ? _session!.messages.length : 0;

  List<ChatSessionWrapper> get sessions => _sessions;

  ChatSessionWrapper? get lastSession => _session;

  int get sessionCount => _sessions.length;

  bool get isGenerating => _session != null
      ? _session!.status == ChatSessionStatus.generating
      : false;
}
