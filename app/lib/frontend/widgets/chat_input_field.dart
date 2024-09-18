import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/backend/private/providers/model.dart';
import 'package:open_local_ui/core/image.dart';
import 'package:open_local_ui/frontend/dialogs/attachments_dropzone.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatInputFieldWidget extends StatefulWidget {
  final ValueNotifier<bool> hasUserInput;

  const ChatInputFieldWidget({super.key, required this.hasUserInput});

  @override
  State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
  static final ImageCacheManager _imageCacheManager = ImageCacheManager();
  final TextEditingController _textEditingController = TextEditingController();

  Uint8List? get _imageBytes =>
      _imageCacheManager.getImage('current_image_embed');

  set _imageBytes(Uint8List? imageBytes) =>
      _imageCacheManager.cacheImage('current_image_embed', imageBytes);

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      widget.hasUserInput.value =
          _textEditingController.text.isNotEmpty || _imageBytes != null;
    });
  }

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
          SnackbarContentType.failure,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    }

    context.read<ChatProvider>().sendMessage(
          _textEditingController.text,
          imageBytes: _imageBytes,
        );

    _textEditingController.clear();

    _imageBytes = null;
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.enter,
          shift: true,
        ): () => _sendMessage(),
      },
      child: Column(
        children: [
          if (_imageBytes != null)
            SizedBox(
              height: 90,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_imageBytes != null)
                      AttachmentsPreviewCardWidget(
                        imageBytes: _imageBytes!,
                        trashButtonCallback: () {
                          setState(() {
                            _imageBytes = null;

                            widget.hasUserInput.value =
                                _textEditingController.text.isNotEmpty ||
                                    _imageBytes != null;
                          });
                        },
                      )
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 600.ms, delay: 300.ms)
                          .move(
                            begin: const Offset(-16, 0),
                            curve: Curves.easeOutQuad,
                          ),
                  ],
                ),
              ),
            ),
          if (_imageBytes != null) const Gap(8.0),
          Container(
            constraints: const BoxConstraints(
              maxHeight: 110,
            ),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).chatInputFieldHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                prefixIcon: context.watch<ChatProvider>().isMultimodalModel
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: IconButton(
                          tooltip: _imageBytes == null
                              ? AppLocalizations.of(context)
                                  .chatAttachFilesTooltip
                              : AppLocalizations.of(context)
                                  .chatDetachFilesTooltip,
                          icon: Icon(
                            _imageBytes == null
                                ? UniconsLine.link_broken
                                : UniconsLine.link,
                          ),
                          onPressed: () async {
                            _imageBytes = await showAttachmentsDropzoneDialog(
                              context,
                              _imageBytes,
                            );

                            setState(() {
                              widget.hasUserInput.value =
                                  _textEditingController.text.isNotEmpty ||
                                      _imageBytes != null;
                            });
                          },
                        ),
                      )
                    : null,
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
                          onPressed: () async => _sendMessage(),
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
        ],
      ),
    );
  }
}

class AttachmentsPreviewCardWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final Function trashButtonCallback;

  const AttachmentsPreviewCardWidget({
    super.key,
    required this.imageBytes,
    required this.trashButtonCallback,
  });

  void addListener(void Function() function) {}

  @override
  State<AttachmentsPreviewCardWidget> createState() =>
      _AttachmentsPreviewCardWidgetState();
}

class _AttachmentsPreviewCardWidgetState
    extends State<AttachmentsPreviewCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          if (_isHovered)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).chatDetachFilesTooltip,
                  icon: const Icon(
                    UniconsLine.trash,
                    color: Colors.red,
                    size: 24,
                  ),
                  onPressed: () => widget.trashButtonCallback(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
