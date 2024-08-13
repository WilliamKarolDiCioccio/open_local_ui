import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';


import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/backend/models/model.dart';
import 'package:open_local_ui/backend/models/ollama_responses.dart';
import 'package:open_local_ui/backend/providers/model_settings.dart';
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/core/http.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/frontend/helpers/snackbar.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

enum ModelProviderStatus {
  idle,
  pulling,
  pushing,
  creating,
}

class ModelProvider extends ChangeNotifier {
  static const _api = 'http://localhost:11434/api';
  static final List<Model> _models = [];
  static late Process _process;
  ModelProviderStatus _status = ModelProviderStatus.idle;

  static Future startOllama() async {
    try {
      // Check if ollama is up and running
      if (!await _isOlamaRunning()) {
        Process.start('ollama', ['serve']).then((Process process) {
          _process = process;

          logger.d('Program started with PID: ${process.pid}');

          process.stdout.transform(utf8.decoder).listen((data) {
            logger.t('stdout: $data');
          });

          process.stderr.transform(utf8.decoder).listen((data) {
            if (!kDebugMode) {
              logger.e('stderr: $data');
            }
          });

          process.exitCode.then((int code) {
            logger.d('Process exited with code $code');
          });
        });
      }

      await _updateListStatic();
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<bool> _isOlamaRunning() async {
    try {
      final response = await HTTPMethods.get('$_api/ps');
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      return false;
    }
  }

  static Future stopOllama() async {
    _process.kill();
  }

  static Future _updateListStatic() async {
    await HTTPMethods.get('$_api/tags').then((response) {
      if (response.statusCode != 200) {
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
    }).catchError((error) {
      logger.e(error);
    });
  }

  Future updateList() async {
    await _updateListStatic();

    notifyListeners();
  }

  Stream<OllamaPullResponse> pull(String name) async* {
    final completer = Completer<void>();

    _status = ModelProviderStatus.pulling;

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
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
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
            WindowsTaskbar.setProgress(
              (modelPullResponse.completed / modelPullResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelPullResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          WindowsTaskbar.resetThumbnailToolbar();
          WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Stream<OllamaPushResponse> push(String name) async* {
    final completer = Completer<void>();

    _status = ModelProviderStatus.pushing;

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
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
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
            WindowsTaskbar.setProgress(
              (modelPushResponse.completed / modelPushResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelPushResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          WindowsTaskbar.resetThumbnailToolbar();
          WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Stream<OllamaCreateResponse> create(String name, String modelfile) async* {
    final completer = Completer<void>();

    _status = ModelProviderStatus.creating;

    final request = http.Request('POST', Uri.parse('$_api/create'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'name': name,
      'modelfile': modelfile,
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      logger.e(
          'Failed to create model $name, status code: ${response.statusCode}');
      return;
    }

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

    if (Platform.isWindows) {
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
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
            WindowsTaskbar.setProgress(
              (modelCreateResponse.completed / modelCreateResponse.total * 100)
                  .toInt(),
              100,
            );
          }

          yield modelCreateResponse;
        }
      } catch (e) {
        if (Platform.isWindows) {
          WindowsTaskbar.resetThumbnailToolbar();
          WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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
      WindowsTaskbar.resetThumbnailToolbar();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
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

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Future remove(String name) async {
    try {
      final response =
          await HTTPMethods.delete('$_api/delete', body: {'name': name});
      if (response.statusCode != 200) {
        logger.e(
            'Failed to remove model $name, status code: ${response.statusCode}');
        return;
      }
      await ModelSettingsProvider.removeStatic(name);

      logger.i('Model $name removed');
    } catch (error) {
      logger.e(error);
    }

    await updateList();
  }

  List<Model> get models => _models;

  static List<Model> getModelsStatic() => _models;

  int get modelsCount => _models.length;

  bool get isPulling => _status == ModelProviderStatus.pulling;

  bool get isPushing => _status == ModelProviderStatus.pushing;

  bool get isCreating => _status == ModelProviderStatus.creating;
}
