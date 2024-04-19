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
}

class ChatController extends ChangeNotifier {
  String _userName = '';
  String _modelName = '';
  bool _webSearch = false;
  bool _docsSearch = true;
  bool _autoScroll = true;
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
    if (text.isEmpty || !isUserSelected || !isModelSelected) {
      addMessage(
          'Please select a model and a user', 'system', ChatMessageType.system);

      _memory.chatHistory.addFunctionChatMessage(
          name: 'system', content: 'Please select a model and a user');

      return;
    }

    _isGenerating = true;

    notifyListeners();

    try {
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

      chain.stream({'input': text}).forEach((response) {
        _messages.last.text += response.toString();
        notifyListeners();
      });

      _memory.chatHistory.addAIChatMessage(_messages.last.text);
    } catch (e) {
      removeLastMessage();

      addMessage('An error occurred while generating the response', 'system',
          ChatMessageType.system);

      _memory.chatHistory.addFunctionChatMessage(
          name: 'system',
          content: 'An error occurred while generating the response');

      logger.e(e);
    }

    _isGenerating = false;

    notifyListeners();
  }

  void removeMessage(String uuid) {
    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);
    notifyListeners();
  }

  void removeLastMessage() {
    _messages.removeLast();
    notifyListeners();
  }

  void regenerateMessage(String uuid, String text) {
    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);
    _memory.chatHistory.removeLast();
    sendMessage(text);
    notifyListeners();
  }

  void clearHistory() {
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

  void enableAutoScroll(bool value) {
    _autoScroll = value;
    notifyListeners();
  }

  String get userName => _userName.isNotEmpty ? _userName : 'Guest';

  String? get modelName => _modelName.isNotEmpty ? _modelName : null;

  bool get isUserSelected => _userName.isNotEmpty;

  bool get isModelSelected => _modelName.isNotEmpty;

  bool get isWebSearchEnabled => _webSearch;

  bool get isDocsSearchEnabled => _docsSearch;

  bool get isAutoScrollEnabled => _autoScroll;

  List<ChatMessage> get history => List.from(_messages);

  ChatMessage getMessage(int index) => _messages[index];

  ChatMessage getLastMessage(int index) => _messages[index - 1];

  ChatMessage get lastMessage => _messages.last;

  List<ChatMessage> get messages => _messages;

  int get messageCount => _messages.length;

  bool get isGenerating => _isGenerating;
}
