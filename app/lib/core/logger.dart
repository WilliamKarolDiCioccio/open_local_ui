import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:open_local_ui/core/formatters.dart';
import 'package:path_provider/path_provider.dart';

late Logger logger;
late File _logFile;

class CombinedOutput extends LogOutput {
  final List<LogOutput> _outputs;

  CombinedOutput(this._outputs);

  @override
  void output(OutputEvent event) {
    for (final output in _outputs) {
      output.output(event);
    }
  }
}

Future<void> initLogger() async {
  late LogOutput logOutput;
  _logFile = await createLogFile();

  Level logLevel = kDebugMode ? Level.all : Level.warning;

  if (kDebugMode) {
    logOutput = CombinedOutput([ConsoleOutput(), FileOutput(file: _logFile)]);
  } else {
    logOutput = FileOutput(file: _logFile);
  }

  logger = Logger(
    filter: null,
    printer: PrettyPrinter(
      lineLength: 80,
      printEmojis: true,
      printTime: true,
    ),
    output: logOutput,
    level: logLevel,
  );
}

Future<File> createLogFile() async {
  final timeStamp = Fortmatters.standardDate(DateTime.now())
      .replaceAll(' ', '_')
      .replaceAll('/', '-')
      .replaceAll(':', '-');

  final directory = await getApplicationSupportDirectory();
  final logFile = File('${directory.path}/logs/log_$timeStamp.log');

  if (!await logFile.exists()) {
    await logFile.parent.create(recursive: true);
  }

  return logFile;
}

File getLogFile() {
  return _logFile;
}
