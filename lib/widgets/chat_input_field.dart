import 'package:flutter/material.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatInputFieldWidget extends StatefulWidget {
  const ChatInputFieldWidget({super.key});

  @override
  State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, value, child) => FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(UniconsLine.message),
                    onPressed: () {
                      final message = _textEditingController.text;
                      Provider.of<ChatController>(context, listen: false)
                          .sendMessage(message);
                      _textEditingController.clear();
                    },
                  ),
                ),
                onSubmitted: (String message) {
                  final provider =
                      Provider.of<ChatController>(context, listen: false);
                  provider.sendMessage(message);
                  _textEditingController.clear();
                },
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
