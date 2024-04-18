// ignore_for_file: unused_field

class ChatMessage {
  String text;
  String sender;
  String dateTime;

  ChatMessage(this.text, this.sender, this.dateTime);
}

class ChatHistoryController {
  static final List<ChatMessage> _messageHistory = [];

  static void addMessage(String message, String sender) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    _messageHistory.add(ChatMessage(
      message,
      sender,
      formattedDateTime,
    ));
  }

  static void removeMessage(int index) {
    _messageHistory.removeAt(index);
  }

  static void clearHistory() {
    _messageHistory.clear();
  }

  static List<ChatMessage> getHistory() {
    return List.from(_messageHistory);
  }

  static ChatMessage getMessage(int index) {
    return _messageHistory[index];
  }

  static ChatMessage getLastMessage() {
    return _messageHistory.last;
  }

  static int getHistoryLength() {
    return _messageHistory.length;
  }
}

class ChatSessionController {
  static String _userName = '';
  static String _modelName = '';
  static bool _webSearch = false;
  static bool _docsSearch = true;
  static bool _autoScroll = true;

  static void setUserName(String userName) {
    _userName = userName;
  }

  static void setModelName(String modelName) {
    _modelName = modelName;
  }

  static String getUserName() {
    return _userName;
  }

  static String getModelName() {
    return _modelName;
  }

  static bool get isUserSelected => _userName.isNotEmpty;

  static bool get isModelSelected => _modelName.isNotEmpty;

  static void enableWebSearch(bool value) {
    _webSearch = value;
  }

  static void enableDocsSearch(bool value) {
    _docsSearch = value;
  }

  static void enableAutoScroll(bool value) {
    _autoScroll = value;
  }

  static bool get isWebSearchEnabled => _webSearch;

  static bool get isDocsSearchEnabled => _docsSearch;

  static bool get isAutoScrollEnabled => _autoScroll;
}
