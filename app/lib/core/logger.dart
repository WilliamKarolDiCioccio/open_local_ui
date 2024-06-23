import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:open_local_ui/core/formatters.dart';
import 'package:path_provider/path_provider.dart';

late Logger logger;

Future<void> initLogger() async {
  final logFile = await _createLogFile();
  logger = Logger(
    filter: null,
    printer: PrettyPrinter(
      lineLength: 80,
      printEmojis: false,
      printTime: true,
    ),
    output: kDebugMode ? ConsoleOutput() : FileOutput(file: logFile),
  );
}

Future<File> _createLogFile() async {
  final timeStamp = Fortmatters.standardDate(DateTime.now())
      .replaceAll(' ', '_')
      .replaceAll('/', '-')
      .replaceAll(':', '-');

  final fileName = 'log_$timeStamp.log';
  final directory = await getApplicationSupportDirectory();
  final logsFolderPath = '${directory.path}/logs';

  await Directory(logsFolderPath).create(recursive: true);
  final logFile = File('$logsFolderPath/$fileName');

  return logFile;
}
