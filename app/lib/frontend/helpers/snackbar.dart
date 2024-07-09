import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:open_local_ui/constants/flutter.dart';

class SnackBarHelpers {
  static void showSnackBar(
    String title,
    String message,
    ContentType type, {
    Duration duration = const Duration(seconds: 5),
    Function? onTap,
  }) async {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: GestureDetector(
        onTap: () => onTap?.call(),
        child: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
      ),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
