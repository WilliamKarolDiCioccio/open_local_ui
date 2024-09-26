// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/backend/private/models/model.dart';
import 'package:open_local_ui/constants/constants.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:path_provider/path_provider.dart';

/// A class for managing model settings within a Flutter app.
///
/// This class is used to load, save, and manage settings for a model.
class ModelSettingsHandler {
  final String modelName;
  late String _activeProfileName;
  final Map<String, ModelSettings> _modelSettingsMap;

  /// Default initializations for late variables are provided in the constructor because the [_init] method runs asynchronously and there is no way to await it in the constructor.
  ModelSettingsHandler(this.modelName)
      : _activeProfileName = 'default',
        _modelSettingsMap = {};

  /// Called when the provider is initialized from [ModelSettingsDialog]. It preloads the settings from the profile associations file.
  /// Calling this in the constructor prevents late initialization errors.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are preloaded.
  Future<void> preloadSettings() async {
    final profileAssociationsFile = await _getProfileAssociationsFile();
    final profileAssociations = jsonDecode(
      await profileAssociationsFile.readAsString(),
    );

    if (!profileAssociations.containsKey(modelName)) {
      profileAssociations[modelName] = 'default';
      profileAssociationsFile.writeAsStringSync(
        jsonEncode(profileAssociations),
      );
    } else {
      _activeProfileName = profileAssociations[modelName];
    }

    // Load all profiles for the current model
    final profileFiles = await getAllModelSettingsProfilesFiles();
    for (final file in profileFiles) {
      final profileName = file.uri.pathSegments.last.replaceAll('.json', '');
      _modelSettingsMap[profileName] = await loadProfile(profileName);
    }

    // If no profiles exist, initialize the default profile
    if (_modelSettingsMap.isEmpty) {
      _modelSettingsMap['default'] = ModelSettings.fromJson({});
    }
  }

  /// Returns the specified settings profile file for the given model.
  Future<File> getModelSettingsProfileFile(
    String modelName,
    String profileName,
  ) async {
    final dir = await getApplicationSupportDirectory();

    final cleanModelName = modelName
        .toLowerCase()
        .replaceAll(RegExp(r'\W'), '_')
        .replaceAll(RegExp(r'_latest$'), '')
        .toLowerCase();

    final file = File(
      '${dir.path}/models_profiles/$cleanModelName/$profileName.json',
    );

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    if (await file.length() == 0) {
      await file.writeAsString(
        jsonEncode(ModelSettings.fromJson({}).toJson()),
      );
    }

    return file;
  }

  /// Returns a list of all model settings files.
  Future<List<File>> getAllModelSettingsProfilesFiles() async {
    final dir = await getApplicationSupportDirectory();

    final cleanModelName = modelName
        .toLowerCase()
        .replaceAll(RegExp(r'\W'), '_')
        .replaceAll(RegExp(r'_latest$'), '')
        .toLowerCase();

    final modelProfilesDir = Directory(
      '${dir.path}/models_profiles/$cleanModelName',
    );

    if (!await modelProfilesDir.exists()) {
      return [];
    }

    return modelProfilesDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();
  }

  /// Returns the profile associations file.
  Future<File> _getProfileAssociationsFile() async {
    final dir = await getApplicationSupportDirectory();

    final file = File(
      '${dir.path}/models_profiles/profiles_associations.json',
    );

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    if (await file.length() == 0) {
      await file.writeAsString('{}');
    }

    return file;
  }

  /// Returns the active profile name for the given model.
  Future<String> getAssociatedProfileName(String modelName) async {
    final profileAssociationsFile = await _getProfileAssociationsFile();
    final profileAssociations = jsonDecode(
      await profileAssociationsFile.readAsString(),
    );

    return profileAssociations[modelName];
  }

  /// Activates and loads the given profile. Updates the profile associations file.
  /// If the [profileName] parameter is `null`, it loads the active profile.
  ///
  /// Returns a [Future] that evaluates to the [ModelSettings] object.
  Future<ModelSettings> activateProfile(String? profileName) async {
    if (profileName == null) return _modelSettingsMap[_activeProfileName]!;

    final profileAssociationsFile = await _getProfileAssociationsFile();
    final profileAssociations = jsonDecode(
      await profileAssociationsFile.readAsString(),
    );

    profileAssociations[modelName] = profileName;
    profileAssociationsFile.writeAsStringSync(
      jsonEncode(profileAssociations),
    );

    _activeProfileName = profileName;
    _modelSettingsMap[profileName] ??= await loadProfile(profileName);

    return _modelSettingsMap[profileName]!;
  }

  /// Loads the given settings profile file. It does not update the active profile.
  /// If the profile does not exist, it returns an empty settings object.
  ///
  /// Returns the a [ModelSettings] object.
  Future<ModelSettings> loadProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final settingsFile =
        await getModelSettingsProfileFile(modelName, profileName);

    if (await settingsFile.exists()) {
      return ModelSettings.fromJson(
        jsonDecode(settingsFile.readAsStringSync()),
      );
    }

    return ModelSettings.fromJson({});
  }

  /// Saves the settings to the given profile.
  /// If the [profileName] parameter is `null`, it saves to the active profile.
  Future<void> saveProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final cleanProfileName = profileName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final settingsFile = await getModelSettingsProfileFile(
      modelName,
      cleanProfileName,
    );

    if (!await settingsFile.exists()) {
      await settingsFile.create(recursive: true);
    }

    await settingsFile.writeAsString(
      jsonEncode(_modelSettingsMap[profileName]!.toJson()),
    );

    await loadProfile(profileName);
  }

  /// Resets the profile settings to default.
  Future<void> resetProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final settingsFile =
        await getModelSettingsProfileFile(modelName, profileName);

    await settingsFile.writeAsString(jsonEncode(<String, dynamic>{}));

    _modelSettingsMap[profileName] = ModelSettings.fromJson({});
    await loadProfile(profileName);
  }

  /// Removes the settings file for the given model.
  Future<void> removeProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final settingsFile =
        await getModelSettingsProfileFile(modelName, profileName);
    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }

    _modelSettingsMap.remove(profileName);
  }

  /// Removes all profiles for the model.
  Future<void> removeAllProfiles() async {
    final dir = await getApplicationSupportDirectory();

    final cleanModelName = modelName
        .toLowerCase()
        .replaceAll(RegExp(r'\W'), '_')
        .replaceAll(RegExp(r'_latest$'), '')
        .toLowerCase();

    final profilesDir =
        Directory('${dir.path}/models_profiles/$cleanModelName');

    if (await profilesDir.exists()) {
      await profilesDir.delete(recursive: true);
    }

    _modelSettingsMap.clear();
  }

  /// Returns the active model settings.
  ModelSettings get activeModelSettings =>
      _modelSettingsMap[_activeProfileName]!;

  /// Returns the active profile name.
  String get activeProfileName => _activeProfileName;

  /// Returns the map of all model settings.
  Map<String, ModelSettings> get modelSettingsMap => _modelSettingsMap;

  /// Sets the active model settings.
  set activeModelSettings(ModelSettings settings) {
    _modelSettingsMap[_activeProfileName] = settings;
  }

  /// Sets the active profile name.
  set activeProfileName(String profileName) {
    _activeProfileName = profileName;
  }
}

/// A provider class for managing model settings within a Flutter app.
///
/// Extends [ModelSettingsHandler] and adds [ChangeNotifier] to notify listeners when settings are changed.
class ModelSettingsProvider extends ModelSettingsHandler with ChangeNotifier {
  bool _isDirty = false;

  ModelSettingsProvider(super.modelName);

  @override
  Future<ModelSettings> activateProfile(String? profileName) async {
    final settings = await super.activateProfile(profileName);
    notifyListeners();
    return settings;
  }

  @override
  Future<ModelSettings> loadProfile(String? profileName) async {
    final settings = await super.loadProfile(profileName);
    notifyListeners();
    return settings;
  }

  @override
  Future<void> saveProfile(String? profileName) async {
    _isDirty = false;
    await super.saveProfile(profileName);
    notifyListeners();
  }

  @override
  Future<void> resetProfile(String? profileName) async {
    _isDirty = false;
    await super.resetProfile(profileName);
    notifyListeners();
  }

  @override
  Future<void> removeProfile(String? profileName) async {
    await super.removeProfile(profileName);
    notifyListeners();
  }

  @override
  Future<void> removeAllProfiles() async {
    await super.removeAllProfiles();
    notifyListeners();
  }

  /// Returns the value of a setting.
  ///
  /// The [settingName] parameter is the name of the setting to get.
  ///
  /// Returns the value of the setting.
  dynamic get(String? profileName, String settingName) {
    late String profile;

    if (profileName != null) {
      profile = profileName;
    } else {
      profile = super.activeProfileName;
    }

    switch (settingName) {
      case 'systemPrompt':
        return super.modelSettingsMap[profile]!.systemPrompt;
      case 'enableWebSearch':
        return super.modelSettingsMap[profile]!.enableWebSearch;
      case 'enableDocsSearch':
        return super.modelSettingsMap[profile]!.enableDocsSearch;
      case 'keepAlive':
        return super.modelSettingsMap[profile]!.keepAlive;
      case 'temperature':
        return super.modelSettingsMap[profile]!.temperature;
      case 'concurrencyLimit':
        return super.modelSettingsMap[profile]!.concurrencyLimit;
      case 'f16KV':
        return super.modelSettingsMap[profile]!.f16KV;
      case 'frequencyPenalty':
        return super.modelSettingsMap[profile]!.frequencyPenalty;
      case 'logitsAll':
        return super.modelSettingsMap[profile]!.logitsAll;
      case 'lowVram':
        return super.modelSettingsMap[profile]!.lowVram;
      case 'numGpu':
        return super.modelSettingsMap[profile]!.numGpu;
      case 'mainGpu':
        return super.modelSettingsMap[profile]!.mainGpu;
      case 'mirostat':
        return super.modelSettingsMap[profile]!.mirostat;
      case 'mirostatEta':
        return super.modelSettingsMap[profile]!.mirostatEta;
      case 'mirostatTau':
        return super.modelSettingsMap[profile]!.mirostatTau;
      case 'numBatch':
        return super.modelSettingsMap[profile]!.numBatch;
      case 'numCtx':
        return super.modelSettingsMap[profile]!.numCtx;
      case 'numKeep':
        return super.modelSettingsMap[profile]!.numKeep;
      case 'numPredict':
        return super.modelSettingsMap[profile]!.numPredict;
      case 'numThread':
        return super.modelSettingsMap[profile]!.numThread;
      case 'numa':
        return super.modelSettingsMap[profile]!.numa;
      case 'penalizeNewline':
        return super.modelSettingsMap[profile]!.penalizeNewline;
      case 'presencePenalty':
        return super.modelSettingsMap[profile]!.presencePenalty;
      case 'repeatLastN':
        return super.modelSettingsMap[profile]!.repeatLastN;
      case 'repeatPenalty':
        return super.modelSettingsMap[profile]!.repeatPenalty;
      case 'seed':
        return super.modelSettingsMap[profile]!.seed;
      case 'stop':
        return super.modelSettingsMap[profile]!.stop;
      case 'tfsZ':
        return super.modelSettingsMap[profile]!.tfsZ;
      case 'topK':
        return super.modelSettingsMap[profile]!.topK;
      case 'topP':
        return super.modelSettingsMap[profile]!.topP;
      case 'typicalP':
        return super.modelSettingsMap[profile]!.typicalP;
      case 'useMlock':
        return super.modelSettingsMap[profile]!.useMlock;
      case 'useMmap':
        return super.modelSettingsMap[profile]!.useMmap;
      case 'vocabOnly':
        return super.modelSettingsMap[profile]!.vocabOnly;
      default:
        throw ArgumentError('Invalid setting name: $settingName');
    }
  }

  /// Sets the value of a setting.
  ///
  /// The [settingName] parameter is the name of the setting to set, and the [newValue] parameter is the new value of the setting.
  ///
  /// This sets the dirty flag to `true`. The settings are not saved until the [save] method is called.
  ///
  /// Return a [Future] that evaluates to `void` when the setting is set.
  Future<void> set(
    String? profileName,
    String settingName,
    dynamic newValue,
  ) async {
    late String profile;

    if (profileName != null) {
      profile = profileName;
    } else {
      profile = super.activeProfileName;
    }

    switch (settingName) {
      case 'systemPrompt':
        super.modelSettingsMap[profile]!.systemPrompt = newValue;
        break;
      case 'enableWebSearch':
        super.modelSettingsMap[profile]!.enableWebSearch = newValue;
        break;
      case 'enableDocsSearch':
        super.modelSettingsMap[profile]!.enableDocsSearch = newValue;
        break;
      case 'keepAlive':
        super.modelSettingsMap[profile]!.keepAlive = newValue;
        break;
      case 'temperature':
        super.modelSettingsMap[profile]!.temperature = newValue;
        break;
      case 'concurrencyLimit':
        super.modelSettingsMap[profile]!.concurrencyLimit = newValue;
        break;
      case 'f16KV':
        super.modelSettingsMap[profile]!.f16KV = newValue;
        break;
      case 'frequencyPenalty':
        super.modelSettingsMap[profile]!.frequencyPenalty = newValue;
        break;
      case 'logitsAll':
        super.modelSettingsMap[profile]!.logitsAll = newValue;
        break;
      case 'lowVram':
        super.modelSettingsMap[profile]!.lowVram = newValue;
        break;
      case 'numGpu':
        super.modelSettingsMap[profile]!.numGpu = newValue;
        if (newValue == 0) {
          SnackBarHelpers.showSnackBar(
            AppLocalizations.of(scaffoldMessengerKey.currentContext!)
                .snackBarWarningTitle,
            AppLocalizations.of(scaffoldMessengerKey.currentContext!)
                .ollamaDisabledGPUWarningSnackBar,
            SnackbarContentType.warning,
          );
        }
        break;
      case 'mainGpu':
        super.modelSettingsMap[profile]!.mainGpu = newValue;
        break;
      case 'mirostat':
        super.modelSettingsMap[profile]!.mirostat = newValue;
        break;
      case 'mirostatEta':
        super.modelSettingsMap[profile]!.mirostatEta = newValue;
        break;
      case 'mirostatTau':
        super.modelSettingsMap[profile]!.mirostatTau = newValue;
        break;
      case 'numBatch':
        super.modelSettingsMap[profile]!.numBatch = newValue;
        break;
      case 'numCtx':
        super.modelSettingsMap[profile]!.numCtx = newValue;
        break;
      case 'numKeep':
        super.modelSettingsMap[profile]!.numKeep = newValue;
        break;
      case 'numPredict':
        super.modelSettingsMap[profile]!.numPredict = newValue;
        break;
      case 'numThread':
        super.modelSettingsMap[profile]!.numThread = newValue;
        break;
      case 'numa':
        super.modelSettingsMap[profile]!.numa = newValue;
        break;
      case 'penalizeNewline':
        super.modelSettingsMap[profile]!.penalizeNewline = newValue;
        break;
      case 'presencePenalty':
        super.modelSettingsMap[profile]!.presencePenalty = newValue;
        break;
      case 'repeatLastN':
        super.modelSettingsMap[profile]!.repeatLastN = newValue;
        break;
      case 'repeatPenalty':
        super.modelSettingsMap[profile]!.repeatPenalty = newValue;
        break;
      case 'seed':
        super.modelSettingsMap[profile]!.seed = newValue;
        break;
      case 'stop':
        super.modelSettingsMap[profile]!.stop = newValue;
        break;
      case 'tfsZ':
        super.modelSettingsMap[profile]!.tfsZ = newValue;
        break;
      case 'topK':
        super.modelSettingsMap[profile]!.topK = newValue;
        break;
      case 'topP':
        super.modelSettingsMap[profile]!.topP = newValue;
        break;
      case 'typicalP':
        super.modelSettingsMap[profile]!.typicalP = newValue;
        break;
      case 'useMlock':
        super.modelSettingsMap[profile]!.useMlock = newValue;
        break;
      case 'useMmap':
        super.modelSettingsMap[profile]!.useMmap = newValue;
        break;
      case 'vocabOnly':
        super.modelSettingsMap[profile]!.vocabOnly = newValue;
        break;
      default:
        throw ArgumentError('Invalid setting name: $settingName');
    }

    _isDirty = true;

    notifyListeners();
  }

  /// Returns whether the settings have been modified since the last save and have not been saved yet.
  bool get isDirty => _isDirty;
}
