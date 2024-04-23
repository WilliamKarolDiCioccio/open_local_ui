import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:uuid/uuid.dart';

import 'package:open_local_ui/helpers/langchain.dart';
import 'package:open_local_ui/utils/logger.dart';

enum ChatMessageType { user, model, system }

class ChatMessage {
  String text;
  final Uint8List? imageBytes;
  final String dateTime;
  final String uuid;
  final ChatMessageType type;

  ChatMessage(this.text, this.dateTime, this.uuid, this.type,
      {this.imageBytes});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      json['text'] as String,
      json['dateTime'] as String,
      json['uuid'] as String,
      ChatMessageType.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'dateTime': dateTime,
      'uuid': uuid,
      'type': type.index,
    };
  }
}

class ChatProvider extends ChangeNotifier {
  String _modelName = '';
  bool _webSearch = false;
  bool _docsSearch = true;
  bool _isGenerating = false;
  late ChatOllama _model;
  final _memory = ConversationBufferMemory(returnMessages: true);
  final List<ChatMessage> _messages = [];

  void addMessage(String message, ChatMessageType type) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final uuid = const Uuid().v4();

    _messages.add(ChatMessage(
      message,
      formattedDateTime,
      uuid,
      type,
    ));

    notifyListeners();
  }

  void sendMessage(String text, Uint8List? imageBytes) async {
    if (text.isEmpty || isGenerating) {
      return;
    } else if (!isModelSelected) {
      addMessage('Please select a model.', ChatMessageType.system);

      return;
    }

    try {
      _isGenerating = true;

      notifyListeners();

      addMessage(text, ChatMessageType.user);

      _memory.chatHistory.addHumanChatMessage(_messages.last.text);

      final promptTemplate = ChatPromptTemplate.fromPromptMessages(const [
        MessagesPlaceholder(variableName: 'history'),
      ]);

      final chain = LangchainHelpers.buildConversationChain(
        promptTemplate,
        _model,
        _memory,
      );

      final prompt = ChatMessageContent.multiModal(
        [
          ChatMessageContent.text(text),
          ChatMessageContent.image(
            data: base64.encode(
              imageBytes ?? Uint8List(0).map((e) => e.toInt()).toList(),
            ),
          ),
        ],
      );

      addMessage('', ChatMessageType.model);

      await chain.stream({prompt}).forEach((response) {
        _messages.last.text += response.toString();
        notifyListeners();
      });

      _memory.chatHistory.addAIChatMessage(_messages.last.text);

      _isGenerating = false;

      notifyListeners();
    } catch (e) {
      _isGenerating = false;

      removeLastMessage();

      addMessage('An error occurred while generating the response.',
          ChatMessageType.system);

      logger.e(e);
    }
  }

  void removeMessage(String uuid) async {
    if (_isGenerating) return;

    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);

    for (var i = 0; i < messageCount - index; ++i) {
      _memory.chatHistory.removeLast();
    }

    notifyListeners();
  }

  void removeLastMessage() async {
    if (_isGenerating) return;

    _messages.removeLast();
    _memory.chatHistory.removeLast();

    notifyListeners();
  }

  void regenerateMessage(String uuid, String text) async {
    if (_isGenerating) return;

    Uint8List? imageBytes = lastMessage.imageBytes;

    removeMessage(uuid);

    sendMessage(text, imageBytes);
  }

  void resendMessage(String uuid, String text) async {
    if (_isGenerating) return;

    regenerateMessage(uuid, text);
  }

  void clearHistory() async {
    _isGenerating = false;

    _messages.clear();
    _memory.chatHistory.clear();

    notifyListeners();
  }

  void setModel(String name, {double temperature = 0.0}) {
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

  void enableWebSearch(bool value) {
    _webSearch = value;

    notifyListeners();
  }

  void enableDocsSearch(bool value) {
    _docsSearch = value;

    notifyListeners();
  }

  String get modelName => _modelName;

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
