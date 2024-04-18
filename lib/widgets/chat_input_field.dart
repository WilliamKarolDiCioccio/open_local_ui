import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ChatInputFieldWidget extends StatefulWidget {
  final Function(String) sendMessage;

  const ChatInputFieldWidget({required this.sendMessage, super.key});

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
                      widget.sendMessage(message);
                      _textEditingController.clear();
                    },
                  ),
                ),
                onSubmitted: (String message) {
                  widget.sendMessage(message);
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
