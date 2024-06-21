import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/widgets/chat_example_questions.dart';

import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_message_list.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  Widget _buildInnerWidget(BuildContext context) {
    if (context.watch<ChatProvider>().messageCount == 0) {
      return const ChatExampleQuestions();
    } else {
      return const ChatMessageList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            context.read<ChatProvider>().newSession,
      },
      child: Column(
        children: [
          const ChatToolbarWidget(),
          const SizedBox(height: 16.0),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: _buildInnerWidget(context),
            ),
          ),
          const FractionallySizedBox(
            widthFactor: 0.6,
            child: ChatInputFieldWidget(),
          ),
        ],
      ),
    );
  }
}
