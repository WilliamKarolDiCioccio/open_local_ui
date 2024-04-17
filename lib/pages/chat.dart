import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/helpers/langchain_helpers.dart';
import 'package:open_local_ui/controller/chat_controller.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:open_local_ui/widgets/page_base.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final model = ChatOllama();
  bool _isLoading = false;
  int _messagesCnt = 0;

  @override
  void initState() {
    super.initState();
    _loadMoreMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        final historyLenght = ChatHistoryController.getHistoryLength();

        if ((historyLenght - _messagesCnt) > 10) {
          _messagesCnt += 10;
        } else {
          _messagesCnt += historyLenght - _messagesCnt;
        }

        _isLoading = false;
      });
    }
  }

  void _autoScroll() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _updateMessagesCnt() {
    setState(() {
      _messagesCnt = ChatHistoryController.getHistoryLength();
    });
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    if (!ChatSessionController.isModelSelected() ||
        !ChatSessionController.isModelSelected()) {
      ChatHistoryController.addMessage(
        'Please select a model and a user',
        ChatSessionController.getModelName(),
      );

      _updateMessagesCnt();

      return;
    }

    ChatHistoryController.addMessage(text, ChatSessionController.getUserName());

    _updateMessagesCnt();

    _autoScroll();

    final prompt = PromptValue.string(text);

    final chain = LangchainHelpers.buildConversationChain(text, model);

    final stream = chain.stream(prompt);

    ChatHistoryController.addMessage('', ChatSessionController.getModelName());

    _updateMessagesCnt();

    await stream.forEach((response) {
      ChatHistoryController.getLastMessage().text += response;

      setState(() {});
    });

    _autoScroll();
  }

  @override
  Widget build(BuildContext context) {
    return PageBase(
      body: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messagesCnt,
              itemBuilder: (context, index) {
                final message = ChatHistoryController.getMessage(index);
                if (index == _messagesCnt - 1 && _isLoading) {
                  return const Center(child: LinearProgressIndicator());
                }
                return Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: ChatMessageWidget(
                      text: message.text,
                      sender: message.sender,
                      dateTime: message.dateTime,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: [
            DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              enableFilter: true,
              enableSearch: true,
              label: const Text('Model'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'llama2', label: 'llama2'),
              ],
              onSelected: (value) =>
                  ChatSessionController.setModelName(value ?? ''),
            ),
            const Spacer(),
            DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              enableFilter: true,
              enableSearch: true,
              label: const Text('User'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Wilielmus', label: 'Wilielmus'),
              ],
              onSelected: (value) =>
                  ChatSessionController.setUserName(value ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(UniconsLine.message),
                    onPressed: () {
                      final message = _textEditingController.text;
                      _sendMessage(message);
                      _textEditingController.clear();
                    },
                  ),
                ),
                onSubmitted: (String message) {
                  _sendMessage(message);
                  _textEditingController.clear();
                },
                autofocus: true,
                maxLength: 4096,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
