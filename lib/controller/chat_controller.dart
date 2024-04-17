
const int ollamaDefaultPort = 11434;

class ChatMessage {
   String text;
   String sender;
   DateTime time;

  ChatMessage(this.text, this.sender, this.time);
}

class ChatHistoryController {
  final List<ChatMessage> _messageHistory = [];

  void addMessage(String message, String sender, DateTime time) async {
    _messageHistory.add(ChatMessage(message, sender, time));
  }

  void removeMessage(int index) async {
    _messageHistory.removeAt(index);
  }

  void clearHistory() async {
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
}

final ChatHistoryController chatHistoryController =
    ChatHistoryController();

class ChatSessionController {
  String _userName = '';
  String _modelName = '';

  void setUserName(String userName) {
    _userName = userName;
  }

  void setModelName(String modelName) {
    _modelName = modelName;
  }

  String getUserName() {
    return _userName;
  }

  String getModelName() {
    return _modelName;
  }

  bool isUserSelected() {
    return _userName.isNotEmpty;
  }

  bool isModelSelected() {
    return _modelName.isNotEmpty;
  }
}

final ChatSessionController chatSessionController =
    ChatSessionController();
