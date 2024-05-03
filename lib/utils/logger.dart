import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  filter: null,
  printer: PrettyPrinter(
    lineLength: 80,
    printEmojis: false,
    printTime: true,
  ),
  output: kDebugMode ? null : FileOutput(file: _createLogFile()),
);

File _createLogFile() {
  final timeStamp =
      DateTime.now().toString().split('.').first.replaceAll(' ', '_');
  final fileName = 'log_$timeStamp.txt';
  var logsFolderPath = '';

  if (!kIsWeb) {
    getApplicationDocumentsDirectory().then((directory) {
      logsFolderPath = '${directory.path}/open_local_ui/logs';
      Directory(logsFolderPath).create(recursive: true).then((_) {
        return File('$logsFolderPath/$fileName');
      });
    });
  }

  return File('$logsFolderPath/$fileName');
}
