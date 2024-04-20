import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _sendMessage() {
    final provider = Provider.of<ChatController>(context, listen: false);

    if (provider.isGenerating) {
      final snackBar = SnackBar(
        content: const Text(
          'Model is generating a response, please wait...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final message = _textEditingController.text;

      provider.sendMessage(message);

      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
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
                  tooltip: 'Send message',
                  icon: const Icon(UniconsLine.message),
                  onPressed: () => _sendMessage(),
                ),
              ),
              autofocus: true,
              maxLength: 1024,
              maxLines: null,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
          ),
        ],
      ),
    );
  }
}
