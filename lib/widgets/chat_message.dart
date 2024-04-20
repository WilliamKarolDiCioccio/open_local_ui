import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget(
    this.message, {
    super.key,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  void _regenerateMessage() {
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
      provider.regenerateMessage(widget.message.uuid, widget.message.text);
    }
  }

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
                widget.message.sender,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                widget.message.dateTime,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          const Divider(),
          MarkdownBody(
            selectable: true,
            data: widget.message.text,
            extensionSet: md.ExtensionSet(
              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
              [
                md.LinkSyntax(),
                md.CodeSyntax(),
                md.EmojiSyntax(),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Copy text',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.message.text));

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
                    backgroundColor: Colors.green.withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(UniconsLine.copy),
              ),
              const SizedBox(width: 8.0),
              Visibility(
                visible: widget.message.type == ChatMessageType.user,
                child: IconButton(
                  tooltip: 'Regenerate text',
                  onPressed: () => _regenerateMessage(),
                  icon: const Icon(UniconsLine.repeat),
                ),
              ),
              const SizedBox(width: 8.0),
              Visibility(
                visible: widget.message.type == ChatMessageType.user,
                child: IconButton(
                  tooltip: 'Delete text',
                  onPressed: () =>
                      Provider.of<ChatController>(context, listen: false)
                          .removeMessage(widget.message.uuid),
                  icon: const Icon(UniconsLine.trash),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
