import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

import 'package:open_local_ui/helpers/http.dart';
import 'package:open_local_ui/utils/logger.dart';

class Model {
  final String name;
  final DateTime modifiedAt;
  final int size;
  final String digest;
  final ModelDetails details;

  Model({
    required this.name,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'],
      digest: json['digest'],
      details: ModelDetails.fromJson(json['details']),
    );
  }
}

class ModelDetails {
  final String format;
  final String family;
  final List<String>? families;
  final String parameterSize;
  final String quantizationLevel;

  ModelDetails({
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory ModelDetails.fromJson(Map<String, dynamic> json) {
    return ModelDetails(
      format: json['format'],
      family: json['family'],
      families:
          json['families'] != null ? List<String>.from(json['families']) : null,
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}

class ModelPullResponse extends HTTPStreamResponse {
  ModelPullResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });
}

class ModelPushResponse extends HTTPStreamResponse {
  ModelPushResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });
}

class ModelCreateResponse extends HTTPStreamResponse {
  ModelCreateResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });
}

class ModelProvider extends ChangeNotifier {
  static const api = 'http://localhost:11434/api';
  static final _shell = Shell();
  static final List<Model> _models = [];

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
    await HTTPHelpers.get('$api/tags').then((response) {
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

  Stream<ModelPullResponse> pull(String name) async* {
    final request = http.Request('POST', Uri.parse('$api/pull'));
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
          final modelPullResponse = ModelPullResponse(
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

    completer.complete();
  }

  Stream<ModelPushResponse> push(String name) async* {
    final request = http.Request('POST', Uri.parse('$api/push'));
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
          final modelPushResponse = ModelPushResponse(
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

    completer.complete();
  }

  Stream<ModelCreateResponse> create(String name, String modelfile) async* {
    final request = http.Request('POST', Uri.parse('$api/create'));
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
          final modelPushResponse = ModelCreateResponse(
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

    completer.complete();
  }

  Future remove(String name) async {
    await HTTPHelpers.delete('$api/delete', body: {
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
}
