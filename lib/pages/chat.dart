import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';
import 'package:open_local_ui/helpers/langchain_helpers.dart';
import 'package:open_local_ui/controller/chat_controller.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:open_local_ui/layout/page_base.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
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

    if (!ChatSessionController.isModelSelected ||
        !ChatSessionController.isModelSelected) {
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

    ChatSessionController.isAutoScrollEnabled ? _autoScroll() : null;
  }

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      body: Column(
        children: [
          const ChatToolbarWidget(),
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
                      onDelete: () {},
                      onRegenerate: () {},
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          ChatInputFieldWidget(
            sendMessage: (value) {
              _sendMessage(value);
            },
          ),
        ],
      ),
    );
  }
}
