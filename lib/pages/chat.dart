import 'package:flutter/material.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:open_local_ui/layout/page_base.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, value, child) => PageBaseLayout(
        body: Column(
          children: [
            const ChatToolbarWidget(),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: value.getHistoryLength(),
                itemBuilder: (context, index) {
                  final message = value.getMessage(index);
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
            const ChatInputFieldWidget(),
          ],
        ),
      ),
    );
  }
}
