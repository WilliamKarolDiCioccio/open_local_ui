import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/dialogs/image_dropzone.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';

class ChatInputFieldWidget extends StatefulWidget {
  const ChatInputFieldWidget({super.key});

  @override
  State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  String _text = '';
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
      context.read<ChatProvider>().sendMessage(_text, _imageBytes);

      _textEditingController.clear();
      _text = '';
      _imageBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
          _text = _textEditingController.text;

          _sendMessage();
        },
      },
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
                tooltip: AppLocalizations.of(context)!
                    .chatInputFieldEmbedButtonTooltip,
                icon: Icon(
                  _imageBytes == null
                      ? UniconsLine.image_plus
                      : UniconsLine.image_minus,
                ),
                onPressed: () async {
                  final imageBytes = await showImageDropzoneDialog(
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
                    _text = _textEditingController.text;

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
    );
  }
}
