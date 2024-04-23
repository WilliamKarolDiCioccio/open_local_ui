import 'package:flutter/material.dart';

import 'package:conversion_units/conversion_units.dart';

import 'package:open_local_ui/providers/model.dart';

class ModelDetailsDialog extends StatelessWidget {
  final Model model;

  const ModelDetailsDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(model.name),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Modified At: ${model.modifiedAt.toString()}',
          ),
          Text(
            'Size: ${Kilobytes.toGigabytes(model.size.toDouble() / 1024).toStringAsFixed(1)} GB',
          ),
          Text('Digest: ${model.digest}'),
          Text('Format: ${model.details.format}'),
          Text('Family: ${model.details.family}'),
          if (model.details.families != null)
            Text(
              'Families: ${model.details.families!.join(', ')}',
            ),
          Text('Parameter Size: ${model.details.parameterSize}'),
          Text('Quantization Level: ${model.details.quantizationLevel}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

Future<void> showModelDetailsDialog(Model model, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelDetailsDialog(model: model);
    },
  );
}
