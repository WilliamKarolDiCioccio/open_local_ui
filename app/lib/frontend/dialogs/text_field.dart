import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String labelText;
  final String initialValue;
  final ValueChanged<String> onConfirm;

  const TextFieldDialog({
    super.key,
    required this.title,
    required this.labelText,
    required this.onConfirm,
    this.initialValue = '',
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.labelText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context).dialogCancelButtonShared,
          ),
        ),
        TextButton(
          autofocus: true,
          onPressed: () {
            widget.onConfirm(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context).dialogConfirmButtonShared,
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
}

Future<void> showTextFieldDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required ValueChanged<String> onConfirm,
  String initialValue = '',
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return TextFieldDialog(
        title: title,
        labelText: labelText,
        initialValue: initialValue,
        onConfirm: onConfirm,
      );
    },
  );
}
