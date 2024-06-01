import 'package:flutter/material.dart';
import 'package:open_local_ui/scaffold_messenger_key.dart';

enum SnackBarType {
  success,
  info,
  warning,
  error,
}

class SnackBarHelper {
  static void showSnackBar(String message, SnackBarType type) {
    late Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
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

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
