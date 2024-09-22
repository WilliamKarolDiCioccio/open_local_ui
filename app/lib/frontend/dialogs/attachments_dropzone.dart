import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as img;
import 'package:open_local_ui/core/http.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:unicons/unicons.dart';

enum ImageStatus {
  unloaded,
  loading,
  loaded,
  preloaded,
  error,
}

class AttachmentsDropzoneDialog extends StatefulWidget {
  final Uint8List? imageBytes;

  const AttachmentsDropzoneDialog(this.imageBytes, {super.key});

  @override
  State<AttachmentsDropzoneDialog> createState() =>
      _AttachmentsDropzoneDialogState();
}

class _AttachmentsDropzoneDialogState extends State<AttachmentsDropzoneDialog> {
  late Uint8List? _imageBytes;
  late ImageStatus _imageStatus;

  @override
  void initState() {
    super.initState();

    _imageBytes = widget.imageBytes;
    _imageStatus =
        _imageBytes == null ? ImageStatus.unloaded : ImageStatus.preloaded;
  }

  bool _isURL(String str) {
    const urlPattern = r'^(https?:\/\/)?'
        r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|'
        r'((\d{1,3}\.){3}\d{1,3}))'
        r'(:\d+)?(\/[-a-z\d%_.~+]*)*'
        r'(\?[;&a-z\d%_.~+=-]*)?'
        r'(\#[-a-z\d_]*)?$';
    final regExp = RegExp(urlPattern, caseSensitive: false);
    return regExp.hasMatch(str);
  }

  String? _extractUrlFromQuery(String query) {
    final uri = Uri.parse(query);
    final queryParams = uri.queryParameters;

    return queryParams['iai'];
  }

  FutureOr<DropOperation> _onDropOver(DropOverEvent event) async {
    final item = event.session.items.first;

    if (item.canProvide(Formats.plainText) ||
        item.canProvide(Formats.png) ||
        item.canProvide(Formats.jpeg) ||
        item.canProvide(Formats.webp)) {
      return DropOperation.copy;
    } else {
      return DropOperation.none;
    }
  }

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    final item = event.session.items.first;

    final reader = item.dataReader!;

    setState(() {
      _imageStatus = ImageStatus.loading;
    });

    try {
      if (reader.canProvide(Formats.plainText)) {
        reader.getValue<String>(Formats.plainText, (text) async {
          if (text == null) {
            setState(() {
              _imageStatus = ImageStatus.error;
            });

            return;
          }

          String url = '';

          if (_isURL(text)) {
            url = text;
          } else {
            url = _extractUrlFromQuery(text) ?? text;
          }

          final response = await HTTPHelpers.get(url);

          if (response.statusCode != 200) {
            setState(() {
              _imageStatus = ImageStatus.error;
            });

            return;
          }

          final encodedPng = await Image.network(url).pngUint8List;

          setState(() {
            _imageBytes = encodedPng;
            _imageStatus = ImageStatus.loaded;
          });
        });
      } else if (reader.canProvide(Formats.png)) {
        reader.getFile(Formats.png, (file) {
          final stream = file.getStream();
          _setImageFromStream(stream);
        });
      } else if (reader.canProvide(Formats.jpeg)) {
        reader.getFile(Formats.jpeg, (file) {
          final stream = file.getStream();
          _setImageFromStream(stream);
        });
      } else if (reader.canProvide(Formats.webp)) {
        reader.getFile(Formats.webp, (file) async {
          final stream = file.getStream();
          final bytes = await stream.toList();

          final decodedWebP = img.decodeWebP(
            Uint8List.fromList(
              bytes.expand((x) => x).toList(),
            ),
          );

          final encodedPng = img.encodePng(decodedWebP!);

          setState(() {
            _imageBytes = encodedPng;
            _imageStatus = ImageStatus.loaded;
          });
        });
      }
    } catch (e) {
      logger.e('Error while processing dropped file: $e');

      setState(() {
        _imageStatus = ImageStatus.error;
      });
    }
  }

  void _loadFromFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);

      if (result.files.single.extension == 'webp') {
        final image = await file.pngUint8List;

        setState(() {
          _imageBytes = image;
        });
      } else {
        final stream = file.openRead();
        _setImageFromStream(stream);
      }
    }
  }

  Widget _buildDropzone() {
    late Widget innerWidget;

    switch (_imageStatus) {
      case ImageStatus.unloaded:
        innerWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              UniconsLine.cloud_upload,
              size: 64.0,
            ),
            Text(
              AppLocalizations.of(context).attachFilesDialogDropFilesText,
              style: const TextStyle(fontSize: 24.0),
            ),
            Text(
              AppLocalizations.of(context).attachFilesDialogAllowedFormats(
                'PNG, JPEG, WEBP',
              ),
              style: const TextStyle(fontSize: 14.0),
            ),
            const Gap(16.0),
            TextButton.icon(
              label: Text(
                AppLocalizations.of(context).attachFilesDialogBrowseFilesButton,
                style: const TextStyle(fontSize: 16.0),
              ),
              icon: const Icon(UniconsLine.folder),
              onPressed: () => _loadFromFile(),
            ),
          ],
        );
      case ImageStatus.loading:
        innerWidget = SpinKitCircle(
          color: AdaptiveTheme.of(context).mode.isDark
              ? Colors.white
              : Colors.black,
        );
      case ImageStatus.loaded:
      case ImageStatus.preloaded:
        innerWidget = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.fitHeight,
            cacheWidth: 512,
            // cacheHeight is automatically calculated based on the image aspect ratio
          ),
        );
      case ImageStatus.error:
        innerWidget = const Icon(
          UniconsLine.exclamation_triangle,
          size: 64.0,
        );
    }

    return DropRegion(
      formats: const [
        Formats.plainText,
        Formats.png,
        Formats.jpeg,
        Formats.webp,
      ],
      onDropOver: (event) async => await _onDropOver(event),
      onPerformDrop: (event) async => await _onPerformDrop(event),
      child: Center(
        child: innerWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 512.0,
        height: 512.0,
        child: Center(
          child: _buildDropzone(),
        ),
      ),
      actions: [
        if (_imageStatus == ImageStatus.error ||
            _imageStatus != ImageStatus.loaded ||
            _imageStatus != ImageStatus.preloaded)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(widget.imageBytes);
            },
            child: Text(
              AppLocalizations.of(context).dialogCancelButtonShared,
            ),
          ),
        if (_imageStatus == ImageStatus.preloaded)
          TextButton(
            onPressed: () {
              setState(() {
                _imageBytes = null;
                _imageStatus = ImageStatus.unloaded;
              });

              Navigator.of(context).pop(null);
            },
            child: Text(
              AppLocalizations.of(context).dialogRemoveButton,
            ),
          ),
        if (_imageStatus == ImageStatus.loaded)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_imageBytes);
            },
            child: Text(
              AppLocalizations.of(context).dialogAttachButton,
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(
          duration: 200.ms,
        )
        .move(
          begin: const Offset(0, 160),
          curve: Curves.easeOutQuad,
        );
  }

  void _setImageFromStream(Stream<List<int>> stream) async {
    final bytes = await stream.toList();

    setState(() {
      _imageBytes = Uint8List.fromList(bytes.expand((x) => x).toList());
      _imageStatus = ImageStatus.loaded;
    });
  }
}

Future<Uint8List?> showAttachmentsDropzoneDialog(
  BuildContext context,
  Uint8List? imageBytes,
) async {
  return showDialog<Uint8List?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AttachmentsDropzoneDialog(imageBytes);
    },
  );
}
