import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
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
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: context.watch<ChatProvider>().messageCount,
              itemBuilder: (context, index) {
                final message = context.watch<ChatProvider>().messages[index];

                return ChatMessageWidget(message)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .move(
                      begin: const Offset(-16, 0),
                      curve: Curves.easeOutQuad,
                    );
              },
            ),
          ),
        ),
        if (_isScrollButtonVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(
                UniconsLine.arrow_down,
                size: 32.0,
              ),
              onPressed: _scrollToBottom,
            ),
          ),
      ],
    );
  }
}
