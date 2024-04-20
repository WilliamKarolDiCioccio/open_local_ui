import 'package:flutter/material.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:unicons/unicons.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isScrollButtonVisible = false;
      });
    } else {
      setState(() {
        _isScrollButtonVisible = true;
      });
    }
  }

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
                itemCount: value.messageCount,
                itemBuilder: (context, index) {
                  final message = value.getMessage(index);
                  return Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: ChatMessageWidget(message),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: _isScrollButtonVisible,
              child: IconButton(
                icon: const Icon(
                  UniconsLine.arrow_down,
                  size: 32.0,
                ),
                onPressed: _scrollToBottom,
              ),
            ),
            const ChatInputFieldWidget(),
          ],
        ),
      ),
    );
  }
}
