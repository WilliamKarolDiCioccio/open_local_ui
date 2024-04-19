import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/helpers/langchain_helpers.dart';

class ChatMessage {
  String text;
  String sender;
  String dateTime;

  ChatMessage(this.text, this.sender, this.dateTime);
}

class ChatController extends ChangeNotifier {
  final model = ChatOllama();
  String _userName = '';
  String _modelName = '';
  bool _webSearch = false;
  bool _docsSearch = true;
  bool _autoScroll = true;
  final List<ChatMessage> _messageHistory = [];

  void addMessage(String message, String sender) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    _messageHistory.add(ChatMessage(
      message,
      sender,
      formattedDateTime,
    ));

    notifyListeners();
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    if (!isUserSelected || !isModelSelected) {
      addMessage(
        'Please select a model and a user',
        'system',
      );

      notifyListeners();

      return;
    }

    addMessage(text, getUserName());

    notifyListeners();

    final prompt = PromptValue.string(text);

    final chain = LangchainHelpers.buildConversationChain(text, model);

    final stream = chain.stream(prompt);

    addMessage('', getModelName());

    notifyListeners();

    await stream.forEach((response) {
      getLastMessage().text += response;
      notifyListeners();
    });
  }

  void removeMessage(int index) {
    _messageHistory.removeAt(index);
  }

  void clearHistory() {
    _messageHistory.clear();
  }

  List<ChatMessage> getHistory() {
    return List.from(_messageHistory);
  }

  ChatMessage getMessage(int index) {
    return _messageHistory[index];
  }

  ChatMessage getLastMessage() {
    return _messageHistory.last;
  }

  int getHistoryLength() {
    return _messageHistory.length;
  }

  void setUserName(String userName) {
    _userName = userName;
  }

  void setModelName(String modelName) {
    _modelName = modelName;
  }

  String getUserName() {
    if (_userName.isEmpty) {
      return 'Unknown';
    }
    return _userName;
  }

  String getModelName() {
    if (_modelName.isEmpty) {
      return 'Unknown';
    }
    return _modelName;
  }

  bool get isUserSelected => _userName.isNotEmpty;

  bool get isModelSelected => _modelName.isNotEmpty;

  void enableWebSearch(bool value) {
    _webSearch = value;
  }

  void enableDocsSearch(bool value) {
    _docsSearch = value;
  }

  void enableAutoScroll(bool value) {
    _autoScroll = value;
  }

  bool get isWebSearchEnabled => _webSearch;

  bool get isDocsSearchEnabled => _docsSearch;

  bool get isAutoScrollEnabled => _autoScroll;
}
