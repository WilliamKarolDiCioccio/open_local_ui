import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:open_local_ui/core/format.dart';
import 'package:path_provider/path_provider.dart';

late Logger logger;
late File _logFile;

class _CombinedOutput extends LogOutput {
  final List<LogOutput> _outputs;

  _CombinedOutput(this._outputs);

  @override
  void output(OutputEvent event) {
    for (final output in _outputs) {
      output.output(event);
    }
  }
}

/// This function initializes the logger and its executed when the application starts.
///
/// The logger is configured to output logs to the console and a log file, in debug mode, and only to the log file in release mode.
/// The log level is set to [Level.all] in debug mode and [Level.warning] in release mode.
///
/// The log file is stored in the application's support directory (see the output of [getApplicationSupportDirectory]).
Future<void> initLogger() async {
  late LogOutput logOutput;
  _logFile = await _createLogFile();

  Level logLevel = kDebugMode ? Level.all : Level.warning;

  if (kDebugMode) {
    logOutput = _CombinedOutput([ConsoleOutput(), FileOutput(file: _logFile)]);
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

Future<File> _createLogFile() async {
  final timeStamp = FortmatHelpers.standardDate(DateTime.now())
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
