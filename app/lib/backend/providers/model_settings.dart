import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:open_local_ui/backend/models/model.dart';
import 'package:path_provider/path_provider.dart';

class ModelSettingsProvider extends ChangeNotifier {
  final String modelName;
  late ModelSettings _settings;
  bool _isDirty = false;

  ModelSettingsProvider(this.modelName);

  Future<ModelSettings> load() async {
    _settings = await loadStatic(modelName);
    notifyListeners();
    return _settings;
  }

  static Future<ModelSettings> loadStatic(String modelName) async {
    final settingsFile = await _getSettingsFile(modelName);

    if (await settingsFile.exists()) {
      return ModelSettings.fromJson(
        jsonDecode(settingsFile.readAsStringSync()),
      );
    }

    return ModelSettings.fromJson({});
  }

  dynamic get(String settingName) {
    switch (settingName) {
      case 'systemPrompt':
        return _settings.systemPrompt;
      case 'enableWebSearch':
        return _settings.enableWebSearch;
      case 'enableDocsSearch':
        return _settings.enableDocsSearch;
      case 'numGpu':
        return _settings.numGpu;
      case 'keepAlive':
        return _settings.keepAlive;
      case 'temperature':
        return _settings.temperature;
      case 'concurrencyLimit':
        return _settings.concurrencyLimit;
      case 'f16KV':
        return _settings.f16KV;
      case 'frequencyPenalty':
        return _settings.frequencyPenalty;
      case 'logitsAll':
        return _settings.logitsAll;
      case 'lowVram':
        return _settings.lowVram;
      case 'mainGpu':
        return _settings.mainGpu;
      case 'mirostat':
        return _settings.mirostat;
      case 'mirostatEta':
        return _settings.mirostatEta;
      case 'mirostatTau':
        return _settings.mirostatTau;
      case 'numBatch':
        return _settings.numBatch;
      case 'numCtx':
        return _settings.numCtx;
      case 'numKeep':
        return _settings.numKeep;
      case 'numPredict':
        return _settings.numPredict;
      case 'numThread':
        return _settings.numThread;
      case 'numa':
        return _settings.numa;
      case 'penalizeNewline':
        return _settings.penalizeNewline;
      case 'presencePenalty':
        return _settings.presencePenalty;
      case 'repeatLastN':
        return _settings.repeatLastN;
      case 'repeatPenalty':
        return _settings.repeatPenalty;
      case 'seed':
        return _settings.seed;
      case 'stop':
        return _settings.stop;
      case 'tfsZ':
        return _settings.tfsZ;
      case 'topK':
        return _settings.topK;
      case 'topP':
        return _settings.topP;
      case 'typicalP':
        return _settings.typicalP;
      case 'useMlock':
        return _settings.useMlock;
      case 'useMmap':
        return _settings.useMmap;
      case 'vocabOnly':
        return _settings.vocabOnly;
      default:
        throw ArgumentError('Invalid setting name: $settingName');
    }
  }

  Future<void> set(String settingName, dynamic newValue) async {
    switch (settingName) {
      case 'systemPrompt':
        _settings.systemPrompt = newValue;
      case 'enableWebSearch':
        _settings.enableWebSearch = newValue;
      case 'enableDocsSearch':
        _settings.enableDocsSearch = newValue;
      case 'numGpu':
        _settings.numGpu = newValue;
      case 'keepAlive':
        _settings.keepAlive = newValue;
      case 'temperature':
        _settings.temperature = newValue;
      case 'concurrencyLimit':
        _settings.concurrencyLimit = newValue;
      case 'f16KV':
        _settings.f16KV = newValue;
      case 'frequencyPenalty':
        _settings.frequencyPenalty = newValue;
      case 'logitsAll':
        _settings.logitsAll = newValue;
      case 'lowVram':
        _settings.lowVram = newValue;
      case 'mainGpu':
        _settings.mainGpu = newValue;
      case 'mirostat':
        _settings.mirostat = newValue;
      case 'mirostatEta':
        _settings.mirostatEta = newValue;
      case 'mirostatTau':
        _settings.mirostatTau = newValue;
      case 'numBatch':
        _settings.numBatch = newValue;
      case 'numCtx':
        _settings.numCtx = newValue;
      case 'numKeep':
        _settings.numKeep = newValue;
      case 'numPredict':
        _settings.numPredict = newValue;
      case 'numThread':
        _settings.numThread = newValue;
      case 'numa':
        _settings.numa = newValue;
      case 'penalizeNewline':
        _settings.penalizeNewline = newValue;
      case 'presencePenalty':
        _settings.presencePenalty = newValue;
      case 'repeatLastN':
        _settings.repeatLastN = newValue;
      case 'repeatPenalty':
        _settings.repeatPenalty = newValue;
      case 'seed':
        _settings.seed = newValue;
      case 'stop':
        _settings.stop = newValue;
      case 'tfsZ':
        _settings.tfsZ = newValue;
      case 'topK':
        _settings.topK = newValue;
      case 'topP':
        _settings.topP = newValue;
      case 'typicalP':
        _settings.typicalP = newValue;
      case 'useMlock':
        _settings.useMlock = newValue;
      case 'useMmap':
        _settings.useMmap = newValue;
      case 'vocabOnly':
        _settings.vocabOnly = newValue;
        break;
      default:
        throw ArgumentError('Invalid setting name: $settingName');
    }

    _isDirty = true;

    notifyListeners();
  }

  Future<void> save() async {
    _isDirty = false;

    final settingsFile = await _getSettingsFile(modelName);

    if (!await settingsFile.exists()) {
      await settingsFile.parent.create(recursive: true);
    }

    await settingsFile.writeAsString(jsonEncode(_settings.toJson()));

    await load();

    notifyListeners();
  }

  Future<void> reset() async {
    _isDirty = false;

    final settingsFile = await _getSettingsFile(modelName);
    await settingsFile.writeAsString(jsonEncode(<String, dynamic>{}));

    await load();

    notifyListeners();
  }

  static Future<File> _getSettingsFile(String modelName) async {
    final dir = await getApplicationSupportDirectory();
    final cleanName = modelName.toLowerCase().replaceAll(RegExp(r'\W'), '_');
    final settingsFile = File('${dir.path}/models/$cleanName.json');

    return settingsFile;
  }

  bool get isDirty => _isDirty;

  static Future<void> removeStatic(String name) async {
    final settingsFile = await _getSettingsFile(name);
    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }
  }
}
