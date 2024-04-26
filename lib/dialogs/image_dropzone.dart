import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:image/image.dart' as img;
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/helpers/http.dart';

class ImageDropzoneDialog extends StatefulWidget {
  final Uint8List? imageBytes;

  const ImageDropzoneDialog(this.imageBytes, {super.key});

  @override
  State<ImageDropzoneDialog> createState() => _ImageDropzoneDialogState();
}

class _ImageDropzoneDialogState extends State<ImageDropzoneDialog> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();

    _imageBytes = widget.imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 512.0,
        height: 512.0,
        child: Center(
          child: _imageBytes != null
              ? SizedBox(
                  height: 512.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
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
                  onDropOver: (event) async {
                    final item = event.session.items.first;

                    if (item.canProvide(Formats.plainText) ||
                        item.canProvide(Formats.png) ||
                        item.canProvide(Formats.jpeg) ||
                        item.canProvide(Formats.webp)) {
                      return DropOperation.copy;
                    } else {
                      return DropOperation.none;
                    }
                  },
                  onPerformDrop: (event) async {
                    final item = event.session.items.first;

                    final reader = item.dataReader!;

                    if (reader.canProvide(Formats.plainText)) {
                      reader.getValue<String>(Formats.plainText, (link) async {
                        if (link == null) return;

                        final response = await HTTPHelpers.get(link);

                        if (response.statusCode != 200) {
                          return;
                        }

                        final encodedPng =
                            await Image.network(link).pngUint8List;

                        setState(() {
                          _imageBytes = encodedPng;
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

                        final decodedWebP = img.decodeWebP(Uint8List.fromList(
                            bytes.expand((x) => x).toList()));
                        final encodedPng = img.encodePng(decodedWebP!);

                        setState(() {
                          _imageBytes = encodedPng;
                        });
                      });
                    }
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          UniconsLine.cloud_upload,
                          size: 64.0,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .embedImageDialogDropHereText,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .embedImageDialogAllowedFormatsText(
                            'PNG, JPEG, WEBP',
                          ),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 16.0),
                        TextIconButtonComponent(
                          text: AppLocalizations.of(context)!
                              .embedImageDialogBrowseFilesButton,
                          icon: UniconsLine.folder,
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
            AppLocalizations.of(context)!.dialogEmbedButton,
          ),
        ),
      ],
    );
  }

  void _setImageFromStream(Stream<List<int>> stream) async {
    final bytes = await stream.toList();
    setState(() {
      _imageBytes = Uint8List.fromList(bytes.expand((x) => x).toList());
    });
  }
}

Future<Uint8List?> showImageDropzoneDialog(
    BuildContext context, Uint8List? imageBytes) async {
  return showDialog<Uint8List?>(
    context: context,
    builder: (BuildContext context) {
      return ImageDropzoneDialog(imageBytes);
    },
  );
}
