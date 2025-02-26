import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:file_selector/file_selector.dart';
import '../../generated/i18n/app_localizations.dart';
import 'package:flutter_sticky_widgets/flutter_sticky_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/constants/constants.dart';
import 'package:open_local_ui/core/asset.dart';
import 'package:open_local_ui/frontend/utils/snackbar.dart';
import 'package:unicons/unicons.dart';
import 'package:uuid/uuid.dart';

class MarkdownCodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;
  final String programmingLanguage;
  final ScrollController scrollController;

  const MarkdownCodeWrapperWidget(
    this.child,
    this.text,
    this.programmingLanguage,
    this.scrollController, {
    super.key,
  });

  @override
  State<MarkdownCodeWrapperWidget> createState() => _CodeWrapperState();
}

class _CodeWrapperState extends State<MarkdownCodeWrapperWidget> {
  bool _isCopied = false;
  bool _isSaved = false;
  double _markdownBodyHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = _getMarkdownBodySize(context);
      setState(() {
        _markdownBodyHeight = size.height;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _copyMessage() {
    setState(() => _isCopied = true);

    Clipboard.setData(ClipboardData(text: widget.text));

    SnackBarHelpers.showSnackBar(
      AppLocalizations.of(context).snackBarSuccessTitle,
      AppLocalizations.of(context).codeCopiedSnackBar,
      SnackbarContentType.success,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  Future<void> _saveFile() async {
    setState(() => _isSaved = true);

    late FileSaveLocation? saveLocation;

    if (programmingLanguagesFileExt.containsKey(widget.programmingLanguage)) {
      final fileTypeGroup = XTypeGroup(
        label: 'Text Files',
        extensions: programmingLanguagesFileExt[widget.programmingLanguage],
      );

      saveLocation = await getSaveLocation(
        acceptedTypeGroups: [fileTypeGroup],
        suggestedName:
            'snippet.${programmingLanguagesFileExt[widget.programmingLanguage]!.first}',
      );
    } else {
      const fileTypeGroup = XTypeGroup(label: 'Text Files');

      saveLocation = await getSaveLocation(
        acceptedTypeGroups: [fileTypeGroup],
        suggestedName: 'snippet.txt',
      );
    }

    if (saveLocation?.path != null) {
      final File file = File(saveLocation!.path);

      await file.writeAsString(widget.text);

      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(scaffoldMessengerKey.currentContext!)
            .snackBarSuccessTitle,
        'File saved at: ${file.path}',
        SnackbarContentType.success,
      );
    } else {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(scaffoldMessengerKey.currentContext!)
            .snackBarErrorTitle,
        'No directory selected',
        SnackbarContentType.failure,
      );
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isSaved = false);
      }
    });
  }

  Size _getMarkdownBodySize(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size ?? Size.zero;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            widget.child,
            StickyWidget(
              key: Key('codeWrapperStickyWidget${const Uuid().v4()}'),
              initialPosition: StickyPosition(top: 16, right: 16),
              finalPosition: StickyPosition(
                top: _markdownBodyHeight - 56,
                right: 16,
              ),
              controller: widget.scrollController,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.programmingLanguage.isNotEmpty)
                    if (programmingLanguagesLogos
                        .containsKey(widget.programmingLanguage))
                      Tooltip(
                        message: widget.programmingLanguage.toUpperCase(),
                        child: SvgPicture.memory(
                          AssetManager.getAsset(
                            programmingLanguagesLogos[
                                widget.programmingLanguage]!,
                            type: AssetType.binary,
                          ),
                          width: 20,
                          height: 20,
                          // ignore: deprecated_member_use
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                  if (widget.programmingLanguage.isNotEmpty)
                    if (!programmingLanguagesLogos
                        .containsKey(widget.programmingLanguage))
                      SelectionContainer.disabled(
                        child: Text(
                          widget.programmingLanguage.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  const Gap(24.0),
                  IconButton(
                    onPressed: () => _copyMessage(),
                    icon:
                        Icon(_isCopied ? UniconsLine.check : UniconsLine.copy),
                  ),
                  const Gap(16.0),
                  IconButton(
                    onPressed: () => _saveFile(),
                    icon: Icon(_isSaved ? UniconsLine.check : UniconsLine.save),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
