import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';

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
                    Formats.png,
                    Formats.jpeg,
                  ],
                  onDropOver: (event) async {
                    final item = event.session.items.first;

                    if (item.canProvide(Formats.png) ||
                        item.canProvide(Formats.jpeg)) {
                      return DropOperation.copy;
                    } else {
                      return DropOperation.none;
                    }
                  },
                  onPerformDrop: (event) async {
                    final item = event.session.items.first;

                    final reader = item.dataReader!;

                    if (reader.canProvide(Formats.png)) {
                      reader.getFile(Formats.png, (file) {
                        final stream = file.getStream();
                        _setImageFromStream(stream);
                      });
                    } else if (reader.canProvide(Formats.jpeg)) {
                      reader.getFile(Formats.jpeg, (file) {
                        final stream = file.getStream();
                        _setImageFromStream(stream);
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
                        const Text(
                          'Drop an image here',
                          style: TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(height: 16.0),
                        TextIconButtonComponent(
                          text: 'Browse files',
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

                              final stream = file.openRead();
                              _setImageFromStream(stream);
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
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Remove'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_imageBytes);
          },
          child: const Text('Embed'),
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
