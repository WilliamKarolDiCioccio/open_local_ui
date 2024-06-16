import 'package:flutter/material.dart';

import 'package:open_local_ui/scaffold_messenger_key.dart';

enum SnackBarType {
  success,
  info,
  warning,
  error,
}

class SnackBarHelpers {
  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.info:
        return Colors.blue;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.error:
        return Colors.red;
    }
  }

  static void showSnackBar(String message, SnackBarType type) async {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      showCloseIcon: true,
      duration: const Duration(seconds: 3),
      backgroundColor: _getColor(type),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8.0,
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
