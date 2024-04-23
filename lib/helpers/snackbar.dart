import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
}

class SnackBarHelper {
  static void showSnackBar(
    BuildContext context,
    String message,
    SnackBarType type,
  ) {
    late Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
      case SnackBarType.error:
        backgroundColor = Colors.red;
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
