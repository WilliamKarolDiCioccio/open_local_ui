import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_local_ui/controller/chat_controller.dart';
import 'package:unicons/unicons.dart';

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final String sender;
  final String dateTime;

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.sender,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                UniconsLine.user,
                size: 18.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                sender,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            text,
            style: const TextStyle(fontSize: 16.0),
            softWrap: true,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                },
                icon: const Icon(UniconsLine.copy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
