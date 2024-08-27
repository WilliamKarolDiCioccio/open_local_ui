import 'dart:async';
import 'dart:io';
import 'dart:isolate';

class _IsolateData {
  final SendPort sendPort;
  final String command;
  final List<String>? arguments;

  _IsolateData(this.sendPort, this.command, this.arguments);
}

/// A helper class for working with processes and shell commands.
class ProcessHelpers {
  /// Runs a shell command and returns the output as a string.
  ///
  /// Returns a [Future] that completes with the output of the shell command.
  /// The command is executed in a separate isolate to avoid blocking the main thread.
  static Future<String> runShellCommand(
    String command, {
    List<String>? arguments,
  }) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _runShellCommandInIsolate,
      _IsolateData(receivePort.sendPort, command, arguments),
    );
    return await receivePort.first;
  }

  /// Runs a process in a detached mode.
  ///
  /// Returns a [Future] that completes with a [ProcessResult] when the process finishes.
  /// The command is executed in a separate isolate to avoid blocking the main thread.
  static Future<ProcessResult> runDetached(
    String executable, {
    List<String>? arguments,
  }) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _runDetachedInIsolate,
      _IsolateData(receivePort.sendPort, executable, arguments),
    );
    return await receivePort.first;
  }

  static void _runShellCommandInIsolate(_IsolateData data) async {
    final result = await _runShellCommand(data.command, data.arguments);
    data.sendPort.send(result);
  }

  static void _runDetachedInIsolate(_IsolateData data) async {
    final result = await _runDetached(data.command, data.arguments);
    data.sendPort.send(result);
  }

  static Future<String> _runShellCommand(
    String command,
    List<String>? arguments,
  ) async {
    final result = await Process.run(command, arguments ?? []);
    if (result.exitCode == 0) {
      return result.stdout;
    } else {
      throw ProcessException(
        command,
        arguments ?? [],
        result.stderr,
        result.exitCode,
      );
    }
  }

  static Future<ProcessResult> _runDetached(
    String executable,
    List<String>? arguments,
  ) async {
    final process = await Process.start(executable, arguments ?? [],
        mode: ProcessStartMode.detached,);
    return process.exitCode.then((exitCode) {
      return ProcessResult(process.pid, exitCode, '', '');
    });
  }
}
