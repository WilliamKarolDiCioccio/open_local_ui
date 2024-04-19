import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/helpers/langchain_helpers.dart';
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
  late ChatOllama model;
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
      return;
    }

    _isGenerating = true;

    notifyListeners();

    addMessage(text, _userName, ChatMessageType.user);

    final prompt = PromptValue.string(text);
    final chain = LangchainHelpers.buildConversationChain(text, model);
    final stream = chain.stream(prompt);

    addMessage('', _modelName, ChatMessageType.model);

    await stream.forEach((response) {
      _messages.last.text += response;
      notifyListeners();
    });

    _isGenerating = false;

    notifyListeners();
  }

  void removeMessage(String uuid) {
    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);
    notifyListeners();
  }

  void regenerateMessage(String uuid, String text) {
    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);
    sendMessage(text);
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }

  void setUser(String name) {
    _userName = name;
    notifyListeners();
  }

  void setModel(String name) {
    _modelName = name;
    model = ChatOllama(defaultOptions: ChatOllamaOptions(model: name));
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

  ChatMessage get lastMessage => _messages.last;

  List<ChatMessage> get messages => _messages;

  int get messageCount => _messages.length;

  bool get isGenerating => _isGenerating;
}
