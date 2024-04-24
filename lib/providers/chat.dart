import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:uuid/uuid.dart';

import 'package:open_local_ui/utils/logger.dart';

enum ChatMessageSender { user, model, system }

class ChatMessageWrapper {
  String text;
  final Uint8List? imageBytes;
  final String dateTime;
  final String uuid;
  final ChatMessageSender sender;

  ChatMessageWrapper(this.text, this.dateTime, this.uuid, this.sender,
      {this.imageBytes});

  factory ChatMessageWrapper.fromJson(Map<String, dynamic> json) {
    return ChatMessageWrapper(
      json['text'] as String,
      json['dateTime'] as String,
      json['uuid'] as String,
      ChatMessageSender.values[json['sender'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'dateTime': dateTime,
      'uuid': uuid,
      'sender': sender.index,
    };
  }
}

enum ChatProviderStatus {
  idle,
  generating,
}

class ChatProvider extends ChangeNotifier {
  String _modelName = '';
  bool _webSearch = false;
  bool _docsSearch = true;
  late ChatOllama _model;
  final _memory = ConversationBufferMemory(returnMessages: true);
  final List<ChatMessageWrapper> _messages = [];
  ChatProviderStatus _status = ChatProviderStatus.idle;

  void addMessage(String message, ChatMessageSender type) {
    final now = DateTime.now();
    final formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final uuid = const Uuid().v4();

    _messages.add(ChatMessageWrapper(
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
      addMessage('Please select a model.', ChatMessageSender.system);

      return;
    }

    try {
      _status = ChatProviderStatus.generating;

      notifyListeners();

      addMessage(text, ChatMessageSender.user);

      _memory.chatHistory.addHumanChatMessage(_messages.last.text);

      final promptTemplate = ChatPromptTemplate.fromPromptMessages(const [
        MessagesPlaceholder(variableName: 'history'),
        MessagesPlaceholder(variableName: 'input'),
      ]);

      final chain = Runnable.fromMap({
            'input': Runnable.passthrough(),
            'history': Runnable.fromFunction(
              (final _, final __) async {
                final m = await _memory.loadMemoryVariables();
                return m['history'];
              },
            ),
          }) |
          promptTemplate |
          _model |
          const StringOutputParser<ChatResult>();

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

      addMessage('', ChatMessageSender.model);

      await chain.stream([prompt]).forEach((response) {
        _messages.last.text += response.toString();
        notifyListeners();
      });

      _memory.chatHistory.addAIChatMessage(_messages.last.text);

      _status = ChatProviderStatus.idle;

      notifyListeners();
    } catch (e) {
      _status = ChatProviderStatus.idle;

      removeLastMessage();

      addMessage('An error occurred while generating the response.',
          ChatMessageSender.system);

      logger.e(e);
    }
  }

  void removeMessage(String uuid) async {
    if (_status == ChatProviderStatus.generating) return;

    final index = _messages.indexWhere((element) => element.uuid == uuid);
    _messages.removeRange(index, messageCount);

    for (var i = 0; i < messageCount - index; ++i) {
      _memory.chatHistory.removeLast();
    }

    notifyListeners();
  }

  void removeLastMessage() async {
    if (_status == ChatProviderStatus.generating) return;

    _messages.removeLast();
    _memory.chatHistory.removeLast();

    notifyListeners();
  }

  void regenerateMessage(String uuid, String text) async {
    if (_status == ChatProviderStatus.generating) return;

    Uint8List? imageBytes = lastMessage.imageBytes;

    removeMessage(uuid);

    sendMessage(text, imageBytes);
  }

  void resendMessage(String uuid, String text) async {
    if (_status == ChatProviderStatus.generating) return;

    regenerateMessage(uuid, text);
  }

  void clearHistory() async {
    if (_status == ChatProviderStatus.generating) return;

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

  List<ChatMessageWrapper> get history => List.from(_messages);

  ChatMessageWrapper getMessage(int index) => _messages[index];

  ChatMessageWrapper getLastMessage(int index) => _messages[index - 1];

  ChatMessageWrapper get lastMessage => _messages.last;

  List<ChatMessageWrapper> get messages => _messages;

  int get messageCount => _messages.length;

  bool get isGenerating => _status == ChatProviderStatus.generating;
}
