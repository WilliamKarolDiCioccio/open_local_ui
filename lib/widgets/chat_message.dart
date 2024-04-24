import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/extensions/markdown_code.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _textEditingController = TextEditingController();
  bool _isEditing = false;

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message.text));

    SnackBarHelper.showSnackBar(
      context,
      'Message copied to clipboard!',
      SnackBarType.success,
    );
  }

  void _regenerateMessage() {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        context,
        'Model is generating a response, please wait...',
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().regenerateMessage(
            widget.message.uuid,
            widget.message.text,
          );
    }
  }

  void _beginEditingMessage() {
    setState(() {
      _isEditing = true;
    });

    _textEditingController.text = widget.message.text;
  }

  void _resendEditedMessage() {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        context,
        'Model is generating a response, please wait...',
        SnackBarType.error,
      );
    } else {
      final message = _textEditingController.text;

      context.read<ChatProvider>().resendMessage(
            widget.message.uuid,
            message,
          );

      setState(() {
        _isEditing = false;
      });

      _textEditingController.clear();
    }
  }

  void _cancelEditingMessage() {
    setState(() {
      _isEditing = false;
    });

    _textEditingController.clear();
  }

  void _trashMessage() async {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        context,
        'Model is generating a response, please wait...',
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().removeMessage(widget.message.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderName;
    IconData senderIconData;

    switch (widget.message.type) {
      case ChatMessageType.user:
        senderIconData = UniconsLine.user;
        senderName = 'You';
        break;
      case ChatMessageType.model:
        senderIconData = UniconsLine.robot;
        senderName = context.read<ChatProvider>().modelName;
        break;
      case ChatMessageType.system:
        senderIconData = UniconsLine.eye;
        senderName = 'System';
        break;
    }

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
              Icon(
                senderIconData,
                size: 18.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                senderName,
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
          Visibility(
            visible: !_isEditing,
            child: SelectionArea(
              child: MarkdownBody(
                data: widget.message.text,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  ThemeData(
                    textTheme: TextTheme(
                      bodyMedium: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        color: AdaptiveTheme.of(context)
                            .theme
                            .textTheme
                            .bodyMedium
                            ?.color,
                        fontFamily: 'Neuton',
                      ),
                    ),
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href != null) launchUrl(Uri.parse(href));
                },
                builders: {
                  'code': MarkdownCustomCodeBuilder(),
                },
                selectable: true,
              ),
            ),
          ),
          Visibility(
            visible: _isEditing,
            child: Column(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Edit your message...',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  autofocus: true,
                  maxLength: 4096,
                  maxLines: null,
                  expands: false,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                Row(
                  children: [
                    TextIconButtonComponent(
                      text: 'Resend message',
                      icon: UniconsLine.message,
                      onPressed: () => _resendEditedMessage(),
                    ),
                    TextIconButtonComponent(
                      text: 'Cancel editing',
                      icon: UniconsLine.times,
                      onPressed: () => _cancelEditingMessage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Copy text',
                onPressed: () => _copyMessage(),
                icon: const Icon(UniconsLine.copy),
              ),
              const SizedBox(width: 8.0),
              Visibility(
                visible: widget.message.type == ChatMessageType.user,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Regenerate text',
                      onPressed: () => _regenerateMessage(),
                      icon: const Icon(UniconsLine.repeat),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      tooltip: 'Edit text',
                      onPressed: () => _beginEditingMessage(),
                      icon: const Icon(UniconsLine.edit),
                    ),
                    IconButton(
                      tooltip: 'Delete text',
                      onPressed: () => _trashMessage(),
                      icon: const Icon(UniconsLine.trash),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
