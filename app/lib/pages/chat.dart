import 'package:flutter/material.dart';
import 'package:open_local_ui/layout/page_base.dart';

import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_message_list.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBaseLayout(
      body: Column(
        children: [
          ChatToolbarWidget(),
          SizedBox(height: 16.0),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: ChatMessageList(),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ChatInputFieldWidget(),
          ),
        ],
      ),
    );
  }
}
