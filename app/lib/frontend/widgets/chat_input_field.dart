import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    as snackbar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/backend/providers/model.dart';
import 'package:open_local_ui/frontend/helpers/snackbar.dart';
import 'package:open_local_ui/frontend/dialogs/attachments_dropzone.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

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
        return SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).snackBarErrorTitle,
          AppLocalizations.of(context).noModelsAvailableSnackBar,
          snackbar.ContentType.failure,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        snackbar.ContentType.failure,
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
      child: Container(
        padding: const EdgeInsets.only(top: 8.0),
        constraints: const BoxConstraints(
          maxHeight: 200,
        ),
        child: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).chatInputFieldHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: IconButton(
                tooltip: _imageBytes == null
                    ? AppLocalizations.of(context).chatAttachFilesTooltip
                    : AppLocalizations.of(context).chatDetachFilesTooltip,
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
                      tooltip: AppLocalizations.of(context)
                          .chatCancelGenerationTooltip,
                      icon: const Icon(UniconsLine.stop_circle),
                      onPressed: () async {
                        context.read<ChatProvider>().abortGeneration();
                      },
                    )
                  else
                    IconButton(
                      tooltip: AppLocalizations.of(context).chatSendTooltip,
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
          maxLength: TextField.noMaxLength,
          maxLines: null,
          expands: false,
        ),
      ),
    );
  }
}
