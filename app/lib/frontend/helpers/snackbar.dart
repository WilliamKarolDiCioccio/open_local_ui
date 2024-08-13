import 'package:flutter/material.dart';
import 'package:open_local_ui/constants/flutter.dart';

enum SnackbarContentType { success, failure, warning, info }

class SnackBarHelpers {
  static void showSnackBar(
    String title,
    String message,
    SnackbarContentType type, {
    Duration duration = const Duration(seconds: 5),
    Function? onTap,
  }) async {
    // Determine the background color based on the content type
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarContentType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackbarContentType.failure:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackbarContentType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case SnackbarContentType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      elevation: 6.0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      duration: duration,
      content: GestureDetector(
        onTap: () => onTap?.call(),
        child: Row(
          children: [
            Icon(icon, color: Colors.white), // Display appropriate icon
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
