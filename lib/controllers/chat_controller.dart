import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/helpers/langchain_helpers.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:uuid/uuid.dart';

enum ChatMessageType { user, model, system }

class ChatMessage {
  String text;
  final String sender;
  final String dateTime;
  final String uuid;
  final ChatMessageType type;

  ChatMessage(this.text, this.sender, this.dateTime, this.uuid, this.type);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      json['text'] as String,
      json['sender'] as String,
      json['dateTime'] as String,
      json['uuid'] as String,
      ChatMessageType.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'dateTime': dateTime,
      'uuid': uuid,
      'type': type.index,
    };
  }
}

class ChatController extends ChangeNotifier {
  String _userName = '';
  String _modelName = '';
  bool _webSearch = false;
  bool _docsSearch = true;
  bool _isGenerating = false;
  late ChatOllama _model;
  final _memory = ConversationBufferMemory(returnMessages: true);
  final List<ChatMessage> _messages = [];

  void addMessage(String message, String sender, ChatMessageType type) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final uuid = const Uuid().v4();

    _messages.add(ChatMessage(
      message,
      sender,
      formattedDateTime,
      uuid,
      type,
    ));

    notifyListeners();
  }

  void sendMessage(String text) async {
    if (text.isEmpty || isGenerating) {
      return;
    } else if (!isUserSelected || !isModelSelected) {
      addMessage(
          'Please select a model and a user', 'system', ChatMessageType.system);

      _memory.chatHistory.addFunctionChatMessage(
          name: 'system', content: 'Please select a model and a user');

      return;
    }

    try {
      _isGenerating = true;

      notifyListeners();

      addMessage(text, _userName, ChatMessageType.user);

      _memory.chatHistory.addHumanChatMessage(_messages.last.text);

      final promptTemplate = ChatPromptTemplate.fromPromptMessages([
        SystemChatMessagePromptTemplate.fromTemplate(
          'You are a helpful chatbot',
        ),
        const MessagesPlaceholder(variableName: 'history'),
        HumanChatMessagePromptTemplate.fromTemplate('{input}'),
      ]);

      final chain = LangchainHelpers.buildConversationChain(
        promptTemplate,
        _model,
        _memory,
      );

      addMessage('', _modelName, ChatMessageType.model);

      await chain.stream({'input': text}).forEach((response) {
        _messages.last.text += response.toString();
        notifyListeners();
      });

      _memory.chatHistory.addAIChatMessage(_messages.last.text);

      _isGenerating = false;

      notifyListeners();
    } catch (e) {
      _isGenerating = false;

      removeLastMessage();

      addMessage('An error occurred while generating the response', 'system',
          ChatMessageType.system);

      _memory.chatHistory.addFunctionChatMessage(
          name: 'system',
          content: 'An error occurred while generating the response');

      logger.e(e);
    }
  }

  void removeMessage(String uuid) {
    if (_isGenerating) return;

    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);

    notifyListeners();
  }

  void removeLastMessage() {
    if (_isGenerating) return;

    _messages.removeLast();

    notifyListeners();
  }

  void regenerateMessage(String uuid, String text) {
    if (_isGenerating) return;

    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);
    _memory.chatHistory.removeLast();

    sendMessage(text);

    notifyListeners();
  }

  void clearHistory() {
    _isGenerating = false;

    _messages.clear();
    _memory.chatHistory.clear();

    notifyListeners();
  }

  void setUser(String name) {
    _userName = name;

    notifyListeners();
  }

  void setModel(String name) {
    _modelName = name;
    _model = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: name,
        format: OllamaResponseFormat.json,
      ),
    );

    notifyListeners();
  }

  void enableWebSearch(bool value) {
    _webSearch = value;

    notifyListeners();
  }

  void enableDocsSearch(bool value) {
    _docsSearch = value;

    notifyListeners();
  }

  String get userName => _userName.isNotEmpty ? _userName : 'Guest';

  String? get modelName => _modelName.isNotEmpty ? _modelName : null;

  bool get isUserSelected => _userName.isNotEmpty;

  bool get isModelSelected => _modelName.isNotEmpty;

  bool get isWebSearchEnabled => _webSearch;

  bool get isDocsSearchEnabled => _docsSearch;

  List<ChatMessage> get history => List.from(_messages);

  ChatMessage getMessage(int index) => _messages[index];

  ChatMessage getLastMessage(int index) => _messages[index - 1];

  ChatMessage get lastMessage => _messages.last;

  List<ChatMessage> get messages => _messages;

  int get messageCount => _messages.length;

  bool get isGenerating => _isGenerating;
}
