import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_local_ui/backend/private/models/model.dart';
import 'package:open_local_ui/backend/private/models/ollama_responses.dart';
import 'package:open_local_ui/backend/private/providers/model_settings.dart';
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/core/http.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/frontend/utils/snackbar.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

enum OllamaAPIProviderStatus {
  idle,
  pulling,
  pushing,
  creating,
}

/// A provider class for managing Ollama models.
///
/// This class extends the [ChangeNotifier] class, allowing it to notify listeners when the models list changes.
///
/// This class enables direct interaction with the Ollama API to pull, push, create and remove models.
///
/// NOTE: You'll see some methods having a `Static` suffix (see [_updateListStatic]). This is because they are used outside the widget tree where providers are not accessible.
class OllamaAPIProvider extends ChangeNotifier {
  static const _api = 'http://localhost:11434/api';
  final List<Model> _models = [];
  late Process _process;
  OllamaAPIProviderStatus _status = OllamaAPIProviderStatus.idle;

  OllamaAPIProvider._internal();

  static final OllamaAPIProvider _instance = OllamaAPIProvider._internal();

  factory OllamaAPIProvider() {
    return _instance;
  }

  /// Start the Ollama server.
  ///
  /// This method also redirects the stdout and stderr of the Ollama server to the logger.
  ///
  /// Returns a [Future] that resolves when the Ollama server is started.
  Future<void> startOllama() async {
    try {
      if (!await _isOllamaRunning()) {
        _process = await Process.start('ollama', ['serve']);

        logger.d('Program started with PID: ${_process.pid}');

        _process.stdout.transform(utf8.decoder).listen((data) {
          logger.t('stdout: $data');
        });

        _process.stderr.transform(utf8.decoder).listen((data) {
          if (!kDebugMode) {
            logger.e('stderr: $data');
          }
        });

        await _process.exitCode.then((int code) {
          logger.d('Process exited with code $code');
        });
      }

      await updateList();
    } catch (e) {
      logger.e(e);
    }
  }

  /// Check if the Ollama server is running.
  ///
  /// Returns a [Future] that resolves to a [bool] indicating whether the Ollama server is running.
  Future<bool> _isOllamaRunning() async {
    try {
      final response = await HTTPHelpers.get('$_api/ps');
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      return false;
    }
  }

  /// Stop the Ollama server.
  ///
  /// This method sends a SIGKILL signal to the Ollama server process.
  ///
  /// Returns a void once the Ollama server is stopped.
  Future<void> stopOllama() async {
    _process.kill(ProcessSignal.sigkill);
  }

  /// Update the list of models.
  ///
  /// Returns a [Future] that resolves to null when the models list is updated.
  Future<void> updateList() async {
    try {
      final response = await HTTPHelpers.get('$_api/tags');
      if (response.statusCode != HttpStatus.ok) {
        logger.e('Failed to fetch models list');
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> modelsJson = data['models'];

      _models.clear();

      for (final modelJson in modelsJson) {
        _models.add(Model.fromJson(modelJson));
      }

      logger.i('Models list updated');
    } catch (e) {
      logger.e('Error updating models list: $e');
    }

    notifyListeners();
  }

  /// Pull a model from the Ollama registry.
  ///
  /// The [name] parameter is the name of the model to pull.
  ///
  /// Returns a [Stream] of [OllamaPullResponse] objects.
  Stream<OllamaPullResponse> pull(String name) async* {
    final completer = Completer<void>();

    _status = OllamaAPIProviderStatus.pulling;

    final request = http.Request('POST', Uri.parse('$_api/pull'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'name': name,
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      logger
          .e('Failed to pull model $name, status code: ${response.statusCode}');
      return;
    }

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
    }

    await for (var data in stream) {
      try {
        final jsonData = jsonDecode(data);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('status') &&
            jsonData.containsKey('total') &&
            jsonData.containsKey('completed')) {
          final modelPullResponse = OllamaPullResponse(
            status: jsonData['status'] as String,
            total: jsonData['total'] as int,
            completed: jsonData['completed'] as int,
            startTime: startTime,
            currentTime: DateTime.now().toString(),
          );

          if (Platform.isWindows) {
            await WindowsTaskbar.setProgress(
              (modelPullResponse.completed / modelPullResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelPullResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          await WindowsTaskbar.resetThumbnailToolbar();
          await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
        }

        logger.d('Incomplete or invalid JSON received: $data');

        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .snackBarErrorTitle,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .failedToPullModelSnackBar,
          SnackbarContentType.failure,
        );
      }
    }

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    }

    SnackBarHelpers.showSnackBar(
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .snackBarSuccessTitle,
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .modelPulledSuccessfullySnackBar,
      SnackbarContentType.success,
    );

    sleep(
      const Duration(
        seconds: 1,
        milliseconds: 500,
      ),
    );

    await updateList();

    _status = OllamaAPIProviderStatus.idle;

    completer.complete();
  }

  /// Push a model to the Ollama registry.
  ///
  /// The [name] parameter is the name of the model to push.
  ///
  /// Returns a [Stream] of [OllamaPushResponse] objects.
  Stream<OllamaPushResponse> push(String name) async* {
    final completer = Completer<void>();

    _status = OllamaAPIProviderStatus.pushing;

    final request = http.Request('POST', Uri.parse('$_api/push'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'name': name,
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      logger
          .e('Failed to push model $name, status code: ${response.statusCode}');
      return;
    }

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
    }

    await for (var data in stream) {
      try {
        final jsonData = jsonDecode(data);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('status') &&
            jsonData.containsKey('total') &&
            jsonData.containsKey('completed')) {
          final modelPushResponse = OllamaPushResponse(
            status: jsonData['status'] as String,
            total: jsonData['total'] as int,
            completed: jsonData['completed'] as int,
            startTime: startTime,
            currentTime: DateTime.now().toString(),
          );

          if (Platform.isWindows) {
            await WindowsTaskbar.setProgress(
              (modelPushResponse.completed / modelPushResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelPushResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          await WindowsTaskbar.resetThumbnailToolbar();
          await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
        }

        logger.d('Incomplete or invalid JSON received: $data');

        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .snackBarErrorTitle,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .failedToPushModelSnackBar,
          SnackbarContentType.failure,
        );
      }
    }

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    }

    SnackBarHelpers.showSnackBar(
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .snackBarSuccessTitle,
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .modelPushedSuccessfullySnackBar,
      SnackbarContentType.success,
    );

    sleep(
      const Duration(
        seconds: 1,
        milliseconds: 500,
      ),
    );

    await updateList();

    _status = OllamaAPIProviderStatus.idle;

    completer.complete();
  }

  /// Create an Ollama model on local machine using a modelfile.
  ///
  /// The [name] parameter is the name of the model to create.
  /// The [modelfile] parameter is the string containing the model configuration (see https://github.com/ollama/ollama/blob/main/docs/modelfile.md).
  ///
  /// Returns a [Stream] of [OllamaCreateResponse] objects.
  Stream<OllamaCreateResponse> create(String name, String modelfile) async* {
    final completer = Completer<void>();

    _status = OllamaAPIProviderStatus.creating;

    final request = http.Request('POST', Uri.parse('$_api/create'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'name': name,
      'modelfile': modelfile,
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      logger.e(
        'Failed to create model $name, status code: ${response.statusCode}',
      );
      return;
    }

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
    }

    await for (var data in stream) {
      try {
        final jsonData = jsonDecode(data);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('status')) {
          final modelCreateResponse = OllamaCreateResponse(
            status: jsonData['status'] as String,
            total: 0,
            completed: 0,
            startTime: startTime,
            currentTime: DateTime.now().toString(),
          );

          if (Platform.isWindows) {
            await WindowsTaskbar.setProgress(
              (modelCreateResponse.completed / modelCreateResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelCreateResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          await WindowsTaskbar.resetThumbnailToolbar();
          await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
        }

        logger.d('Incomplete or invalid JSON received: $data');

        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .snackBarErrorTitle,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
              .failedToCreateModelSnackBar,
          SnackbarContentType.failure,
        );
      }
    }

    if (Platform.isWindows) {
      await WindowsTaskbar.resetThumbnailToolbar();
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    }

    SnackBarHelpers.showSnackBar(
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .snackBarSuccessTitle,
      // ignore: use_build_context_synchronously
      AppLocalizations.of(scaffoldMessengerKey.currentState!.context)
          .modelCreatedSuccessfullySnackBar,
      SnackbarContentType.success,
    );

    sleep(
      const Duration(
        seconds: 1,
        milliseconds: 500,
      ),
    );

    await updateList();

    _status = OllamaAPIProviderStatus.idle;

    completer.complete();
  }

  /// Remove an Ollama model from local machine.
  ///
  /// The [name] parameter is the name of the model to remove.
  ///
  /// Returns a [Future] that resolves when the model is removed.
  Future remove(String name) async {
    try {
      final response = await HTTPHelpers.delete(
        '$_api/delete',
        body: {'name': name},
      );

      if (response.statusCode != 200) {
        logger.e(
          'Failed to remove model $name, status code: ${response.statusCode}',
        );
        return;
      }

      await ModelSettingsHandler(name).removeAllProfiles();

      logger.i('Model $name removed');
    } catch (error) {
      logger.e(error);
    }

    await updateList();
  }

  List<Model> get models => List.unmodifiable(_models);

  int get modelsCount => _models.length;

  bool get isPulling => _status == OllamaAPIProviderStatus.pulling;

  bool get isPushing => _status == OllamaAPIProviderStatus.pushing;

  bool get isCreating => _status == OllamaAPIProviderStatus.creating;
}
