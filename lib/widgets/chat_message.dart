import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:unicons/unicons.dart';

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final String sender;
  final String dateTime;
  final Function onDelete;
  final Function onRegenerate;

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.sender,
    required this.dateTime,
    required this.onDelete,
    required this.onRegenerate,
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
          MarkdownBody(
            data: text,
            selectable: true,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Copy text',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));

                  final snackBar = SnackBar(
                    content: const Text(
                      'Text copied to clipboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.greenAccent.withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(UniconsLine.copy),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                tooltip: 'Regenerate text',
                onPressed: () => onRegenerate(),
                icon: const Icon(UniconsLine.repeat),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                tooltip: 'Delete message',
                onPressed: () => onDelete(),
                icon: const Icon(UniconsLine.trash),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
