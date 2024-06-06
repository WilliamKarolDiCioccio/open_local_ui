import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/providers/model.dart';
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
  String _text = '';
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (!context.read<ChatProvider>().isModelSelected) {
      if (context.read<ModelProvider>().modelsCount == 0) {
        return SnackBarHelper.showSnackBar(
          AppLocalizations.of(context)!.noModelsAvailableSnackbarText,
          SnackBarType.error,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelper.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    }

    context.read<ChatProvider>().sendMessage(_text, imageBytes: _imageBytes);

    _textEditingController.clear();
    _text = '';
    _imageBytes = null;
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
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: IconButton(
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
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 18.0,
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
