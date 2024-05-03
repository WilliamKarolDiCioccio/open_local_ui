import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_local_ui/helpers/datetime.dart';

final logger = Logger(
  filter: null,
  printer: PrettyPrinter(
    lineLength: 80,
    printEmojis: false,
    printTime: true,
  ),
  output: FileOutput(file: _createLogFile()),
);

File _createLogFile() {
  final timeStamp = DateTimeHelpers.getFormattedDateTime()
      .replaceAll(' ', '_')
      .replaceAll('/', '-')
      .replaceAll(':', '-');

  final fileName = 'log_$timeStamp.log';
  var logsFolderPath = '';

  getApplicationSupportDirectory().then((directory) {
    logsFolderPath = '${directory.path}/logs';
    Directory(logsFolderPath).create(recursive: true).then((_) {
      return File('$logsFolderPath/$fileName');
    });
  });

  return File('$logsFolderPath/$fileName');
}
