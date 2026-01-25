import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log;
import 'package:path/path.dart' as p; // Add path package for cleaner pathing
import 'package:path_provider/path_provider.dart';

/// This class provides a singleton logger instance for the application.
///
/// The logger is configured to output logs to the console and a log file, in debug mode, and only to the log file in release mode.
/// The log level is set to [Level.all] in debug mode and [Level.warning] in release mode.
///
/// The log file is stored in the application's support directory (see the output of [getApplicationSupportDirectory]).
class AppLogger {
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  factory AppLogger() => _instance;

  late log.Logger _logger;
  File? _logFile;

  Future<void> init() async {
    _logFile = await _createLogFile();

    _logger = log.Logger(
      level: kDebugMode ? log.Level.all : log.Level.warning,
      printer: log.PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: log.MultiOutput([
        if (kDebugMode) log.ConsoleOutput(),
        if (_logFile != null) log.FileOutput(file: _logFile!),
      ]),
    );
  }

  log.Logger get logInstance => _logger;

  Future<File> _createLogFile() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final String timeStamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;

      final logDir = Directory(p.join(directory.path, 'logs'));
      if (!await logDir.exists()) await logDir.create(recursive: true);

      return File(p.join(logDir.path, 'log_$timeStamp.log'));
    } catch (e) {
      debugPrint('Failed to create log file: $e');
      return File('fallback.log');
    }
  }

  File? get logFile => _logFile;
}

final appLogger = AppLogger().logInstance;
