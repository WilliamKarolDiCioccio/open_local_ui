import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:unicons/unicons.dart';

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
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: _imageBytes != null
            ? Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
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
                      _setImage(stream);
                    });
                  } else if (reader.canProvide(Formats.jpeg)) {
                    reader.getFile(Formats.jpeg, (file) {
                      final stream = file.getStream();
                      _setImage(stream);
                    });
                  }
                },
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        UniconsLine.cloud_upload,
                        size: 64.0,
                      ),
                      Text(
                        'Drop image here',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
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

  void _setImage(Stream<List<int>> stream) async {
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
