import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

import 'package:open_local_ui/helpers/http.dart';
import 'package:open_local_ui/models/model.dart';
import 'package:open_local_ui/models/ollama_responses.dart';
import 'package:open_local_ui/utils/logger.dart';

enum ModelProviderStatus {
  idle,
  pulling,
  pushing,
  creating,
}

class ModelProvider extends ChangeNotifier {
  static const _api = 'http://localhost:11434/api';
  static final _shell = Shell();
  static final List<Model> _models = [];
  static ModelProviderStatus _status = ModelProviderStatus.idle;

  static Future sServe() async {
    try {
      await _shell.run('ollama serve');
    } catch (error) {
      logger.e(error);
    }
  }

  Future serve() async {
    await ModelProvider.sServe();

    notifyListeners();
  }

  static Future sUpdateList() async {
    await HTTPHelpers.get('$_api/tags').then((response) {
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
    await ModelProvider.sUpdateList();

    notifyListeners();
  }

  Stream<OllamaPullResponse> pull(String name) async* {
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

    final completer = Completer<void>();

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

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

          yield modelPullResponse;
        }
      } catch (e) {
        logger.d('Incomplete or invalid JSON received: $data');
      }
    }

    await updateList();

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Stream<OllamaPushResponse> push(String name) async* {
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

    final completer = Completer<void>();

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

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

          yield modelPushResponse;
        }
      } catch (e) {
        logger.d('Incomplete or invalid JSON received: $data');
      }
    }

    await updateList();

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Stream<OllamaCreateResponse> create(String name, String modelfile) async* {
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

    final completer = Completer<void>();

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    final startTime = DateTime.now().toString();

    await for (var data in stream) {
      try {
        final jsonData = jsonDecode(data);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('status')) {
          final modelPushResponse = OllamaCreateResponse(
            status: jsonData['status'] as String,
            total: 0,
            completed: 0,
            startTime: startTime,
            currentTime: DateTime.now().toString(),
          );

          yield modelPushResponse;
        }
      } catch (e) {
        logger.d('Incomplete or invalid JSON received: $data');
      }
    }

    await updateList();

    _status = ModelProviderStatus.idle;

    completer.complete();
  }

  Future remove(String name) async {
    await HTTPHelpers.delete('$_api/delete', body: {
      'name': name,
    }).then((response) {
      if (response.statusCode != 200) {
        logger.e(
            'Failed to remove model $name, status code: ${response.statusCode}');
        return;
      }

      logger.i('Model $name removed');
    }).catchError((error) {
      logger.e(error);
    });

    updateList();
  }

  Model getModel(int index) {
    return _models[index];
  }

  List<Model> get models => _models;

  int get modelsCount => _models.length;

  bool get isPulling => _status == ModelProviderStatus.pulling;

  bool get isPushing => _status == ModelProviderStatus.pushing;

  bool get isCreating => _status == ModelProviderStatus.creating;
}
