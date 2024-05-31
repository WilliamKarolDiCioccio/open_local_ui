import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/dialogs/attachments_dropzone.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';

class ChatInputFieldWidget extends StatefulWidget {
  const ChatInputFieldWidget({super.key});

  @override
  State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        context,
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    } else {
      final text = _textEditingController.text.trim();

      context.read<ChatProvider>().sendMessage(text, imageBytes: _imageBytes);

      _textEditingController.clear();
      _imageBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
          _sendMessage();
        },
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200,
        ),
        child: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.chatInputFieldHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8.0),
                IconButton(
                  tooltip: _imageBytes == null
                      ? AppLocalizations.of(context)!
                          .chatInputFieldAttachButtonTooltip
                      : AppLocalizations.of(context)!
                          .chatInputFieldDetachButtonTooltip,
                  icon: Icon(
                    _imageBytes == null
                        ? UniconsLine.link_add
                        : UniconsLine.link_broken,
                  ),
                  onPressed: () async {
                    final imageBytes = await showAttachmentsDropzoneDialog(
                      context,
                      _imageBytes,
                    );

                    setState(() {
                      _imageBytes = imageBytes;
                    });
                  },
                ),
                const SizedBox(width: 8.0),
                if (context.watch<ChatProvider>().isGenerating)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!
                        .chatInputFieldCancelButtonTooltip,
                    icon: const Icon(UniconsLine.stop_circle),
                    onPressed: () async {
                      context.read<ChatProvider>().abortGeneration();
                    },
                  )
                else
                  IconButton(
                    tooltip: AppLocalizations.of(context)!
                        .chatInputFieldSendButtonTooltip,
                    icon: const Icon(UniconsLine.message),
                    onPressed: () async {
                      _sendMessage();
                    },
                  ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          style: const TextStyle(
            fontSize: 20.0,
            fontFamily: 'Neuton',
            fontWeight: FontWeight.w300,
          ),
          autofocus: true,
          maxLength: 4096,
          maxLines: null,
          expands: false,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
        ),
      ),
    );
  }
}
