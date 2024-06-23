import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ModelSettingsProvider extends ChangeNotifier {
  ModelSettingsProvider(this.modelName);

  final String modelName;

  Map<String, dynamic> _settings = {};

  Future<bool> loadSettings() async {
    _settings = await loadModelSettings(modelName);
    notifyListeners();
    return true;
  }

  /// Load model specific settings from json file if it exists.
  static Future<Map<String, dynamic>> loadModelSettings(
      String modelName) async {
    Map<String, dynamic> modelSettings = {};
    final settingsFile = await _getSettingsFile(modelName);
    if (await settingsFile.exists()) {
      modelSettings = jsonDecode(await settingsFile.readAsString());
    }
    return modelSettings;
  }

  dynamic get(String settingName) => _settings[settingName];

  Future<void> set(String setting, dynamic newValue) async {
    // Make sure we have the latest settings
    await loadSettings();
    File settingsFile = await _getSettingsFile(modelName);
    if (!await settingsFile.exists()) {
      await settingsFile.parent.create();
    }
    if (newValue == null || (newValue is String && newValue.isEmpty)) {
      _settings.remove(setting);
    } else {
      _settings[setting] = newValue;
    }
    await settingsFile.writeAsString(jsonEncode(_settings));
    notifyListeners();
  }

  static Future<File> _getSettingsFile(String modelName) async {
    final dir = await getApplicationSupportDirectory();
    final cleanName = modelName.toLowerCase().replaceAll(RegExp(r'\W'), '_');
    final settingsFile = File('${dir.path}/models/$cleanName.json');
    return settingsFile;
  }
}
