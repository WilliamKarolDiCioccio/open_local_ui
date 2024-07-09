import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/frontend/widgets/chat_example_questions.dart';
import 'package:open_local_ui/frontend/widgets/chat_input_field.dart';
import 'package:open_local_ui/frontend/widgets/chat_message_list.dart';
import 'package:open_local_ui/frontend/widgets/chat_toolbar.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ValueNotifier<bool> hasUserInput = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    hasUserInput.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    hasUserInput.dispose();

    super.dispose();
  }

  Widget _buildInnerWidget(BuildContext context) {
    if (context.watch<ChatProvider>().messageCount != 0 || hasUserInput.value) {
      return const ChatMessageList();
    } else {
      return const ChatExampleQuestions();
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
          const Gap(16.0),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: _buildInnerWidget(context),
            ),
          ),
          const Gap(16.0),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ChatInputFieldWidget(
              hasUserInput: hasUserInput,
            ),
          ),
        ],
      ),
    );
  }
}
