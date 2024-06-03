import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:image/image.dart' as img;
import 'package:open_local_ui/helpers/http.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:unicons/unicons.dart';

class AttachmentsDropzoneDialog extends StatefulWidget {
  final Uint8List? imageBytes;

  const AttachmentsDropzoneDialog(this.imageBytes, {super.key});

  @override
  State<AttachmentsDropzoneDialog> createState() =>
      _AttachmentsDropzoneDialogState();
}

class _AttachmentsDropzoneDialogState extends State<AttachmentsDropzoneDialog> {
  Uint8List? _imageBytes;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();

    _imageBytes = widget.imageBytes;
  }

  bool isURL(String str) {
    const urlPattern = r'^(https?:\/\/)?' +
        r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' +
        r'((\d{1,3}\.){3}\d{1,3}))' +
        r'(:\d+)?(\/[-a-z\d%_.~+]*)*' +
        r'(\?[;&a-z\d%_.~+=-]*)?' +
        r'(\#[-a-z\d_]*)?$';
    final regExp = RegExp(urlPattern, caseSensitive: false);
    return regExp.hasMatch(str);
  }

  bool isQueryString(String str) {
    const queryStringPattern = r'^[^=&?]+=[^=&?]+(&[^=&?]+=[^=&?]+)*$';
    final regExp = RegExp(queryStringPattern);
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
      _isImageLoading = true;
    });

    try {
      if (reader.canProvide(Formats.plainText)) {
        reader.getValue<String>(Formats.plainText, (text) async {
          if (text == null) return;

          String url = '';

          if (isURL(text)) {
            url = text;
          } else {
            url = _extractUrlFromQuery(text) ?? text;
          }

          final response = await HTTPHelpers.get(url);

          if (response.statusCode != 200) return;

          final encodedPng = await Image.network(url).pngUint8List;

          setState(() {
            _imageBytes = encodedPng;
            _isImageLoading = false;
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
            _isImageLoading = false;
          });
        });
      }
    } catch (e) {
      logger.e('Error while processing dropped file: $e');

      setState(() {
        _isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 512.0,
        height: 512.0,
        child: Center(
          child: _imageBytes != null || _isImageLoading
              ? SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isImageLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Image.memory(
                            _imageBytes!,
                            fit: BoxFit.fitHeight,
                          ),
                  ),
                )
              : DropRegion(
                  formats: const [
                    Formats.plainText,
                    Formats.png,
                    Formats.jpeg,
                    Formats.webp,
                  ],
                  onDropOver: (event) async => await _onDropOver(event),
                  onPerformDrop: (event) async => await _onPerformDrop(event),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          UniconsLine.cloud_upload,
                          size: 64.0,
                        ),
                        Text(
                          AppLocalizations.of(context)!.attachFilesDialogText,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .attachFilesDialogAllowedFormatsText(
                            'PNG, JPEG, WEBP',
                          ),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton.icon(
                          label: Text(
                            AppLocalizations.of(context)!
                                .attachFilesDialogBrowseFilesButton,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          icon: const Icon(UniconsLine.folder),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              allowCompression: false,
                              allowedExtensions: ['png', 'jpeg', 'webp'],
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
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _imageBytes = null;
              _isImageLoading = false;
            });
          },
          child: Text(
            AppLocalizations.of(context)!.dialogResetButton,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(
            AppLocalizations.of(context)!.dialogRemoveButton,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_imageBytes);
          },
          child: Text(
            AppLocalizations.of(context)!.dialogAttachButton,
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
      _isImageLoading = false;
    });
  }
}

Future<Uint8List?> showAttachmentsDropzoneDialog(
    BuildContext context, Uint8List? imageBytes) async {
  return showDialog<Uint8List?>(
    context: context,
    builder: (BuildContext context) {
      return AttachmentsDropzoneDialog(imageBytes);
    },
  );
}
