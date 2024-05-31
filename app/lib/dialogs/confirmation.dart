import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.cancelButtonTextShared,
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
          child: Text(
            AppLocalizations.of(context)!.confirmButtonTextShared,
            style: const TextStyle(
              color: Colors.white,
            ),
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

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
      );
    },
  );
}
