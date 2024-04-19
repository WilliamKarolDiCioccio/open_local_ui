import 'dart:convert';
import 'package:open_local_ui/utils/logger.dart';
import 'package:process_run/shell.dart';
import 'package:http/http.dart' as http;

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

class ModelsController {
  static final _shell = Shell();
  static final List<Model> _models = [];

  static void serve() async {
    try {
      await _shell.run('ollama serve');
    } catch (error) {
      logger.e(error);
    }
  }

  static void pull(String name) {
    _shell.run('ollama pull $name');
  }

  static void push(String name) {
    _shell.run('ollama push $name');
  }

  static void updateList() async {
    final url = Uri.parse('http://localhost:11434/api/tags');

    await http.get(url).then((value) {
      final model = Model.fromJson(jsonDecode(value.body));
      _models.add(model);
    }).catchError((error) {
      logger.e(error);
    });
  }

  static List<Model> get models => _models;
  static int get modelsCount => _models.length;
}
