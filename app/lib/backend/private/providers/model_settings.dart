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
  late ModelSettings _activeModelSettings;

  /// Default initializations for late variables are provided in the constructor because the [_init] method runs asynchronously and there is no way to await it in the constructor.
  ModelSettingsHandler(this.modelName)
      : _activeProfileName = 'default',
        _activeModelSettings = ModelSettings.fromJson({});

  /// Called when the provider is initialized from [ModelSettingsDialog]. It preloads the settings from the profile associations file.
  ///
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
      _activeModelSettings = await loadProfile(_activeProfileName);
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
  ///
  /// If the [profileName] parameter is `null`, it loads the active profile.
  ///
  /// Returns a [Future] that evaluates to the [ModelSettings] object.
  Future<ModelSettings> activateProfile(String? profileName) async {
    if (profileName == null) return _activeModelSettings;

    final profileAssociationsFile = await _getProfileAssociationsFile();
    final profileAssociations = jsonDecode(
      await profileAssociationsFile.readAsString(),
    );

    profileAssociations[modelName] = profileName;

    profileAssociationsFile.writeAsStringSync(
      jsonEncode(profileAssociations),
    );

    _activeProfileName = profileName;
    _activeModelSettings = await loadProfile(_activeProfileName);

    return _activeModelSettings;
  }

  /// Loads the given settings profile file. It does not update the active profile.
  ///
  /// If the profile does not exist, it returns an empty settings object.
  ///
  /// The [profileName] parameter is the name of the profile to load.
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
  ///
  /// If the [profileName] parameter is `null`, it saves to the active profile.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are saved.
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
      await settingsFile.parent.create(recursive: true);
    }

    await settingsFile.writeAsString(jsonEncode(_activeModelSettings.toJson()));

    await loadProfile(profileName);
  }

  /// Resets the profile settings to default.
  Future<void> resetProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final settingsFile =
        await getModelSettingsProfileFile(modelName, profileName);

    await settingsFile.writeAsString(jsonEncode(<String, dynamic>{}));

    await loadProfile(profileName);
  }

  /// Removes the settings file for the given model.
  ///
  /// If the [profileName] parameter is `null`, it removes the active profile.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are removed.
  Future<void> removeProfile(String? profileName) async {
    profileName ??= _activeProfileName;

    final settingsFile =
        await getModelSettingsProfileFile(modelName, profileName);
    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }
  }

  /// Removes all profiles for the model.
  ///
  /// The [modelName] parameter is the name of the model.
  ///
  /// Returns a [Future] that evaluates to `void` when the profiles are removed.
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
  }

  /// Returns the active model settings.
  ModelSettings get activeModelSettings => _activeModelSettings;

  /// Returns the active profile name.
  String get activeProfileName => _activeProfileName;

  /// Sets the active model settings.
  set activeModelSettings(ModelSettings settings) {
    _activeModelSettings = settings;
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
  dynamic get(String settingName) {
    switch (settingName) {
      case 'systemPrompt':
        return super.activeModelSettings.systemPrompt;
      case 'enableWebSearch':
        return super.activeModelSettings.enableWebSearch;
      case 'enableDocsSearch':
        return super.activeModelSettings.enableDocsSearch;
      case 'keepAlive':
        return super.activeModelSettings.keepAlive;
      case 'temperature':
        return super.activeModelSettings.temperature;
      case 'concurrencyLimit':
        return super.activeModelSettings.concurrencyLimit;
      case 'f16KV':
        return super.activeModelSettings.f16KV;
      case 'frequencyPenalty':
        return super.activeModelSettings.frequencyPenalty;
      case 'logitsAll':
        return super.activeModelSettings.logitsAll;
      case 'lowVram':
        return super.activeModelSettings.lowVram;
      case 'numGpu':
        return super.activeModelSettings.numGpu;
      case 'mainGpu':
        return super.activeModelSettings.mainGpu;
      case 'mirostat':
        return super.activeModelSettings.mirostat;
      case 'mirostatEta':
        return super.activeModelSettings.mirostatEta;
      case 'mirostatTau':
        return super.activeModelSettings.mirostatTau;
      case 'numBatch':
        return super.activeModelSettings.numBatch;
      case 'numCtx':
        return super.activeModelSettings.numCtx;
      case 'numKeep':
        return super.activeModelSettings.numKeep;
      case 'numPredict':
        return super.activeModelSettings.numPredict;
      case 'numThread':
        return super.activeModelSettings.numThread;
      case 'numa':
        return super.activeModelSettings.numa;
      case 'penalizeNewline':
        return super.activeModelSettings.penalizeNewline;
      case 'presencePenalty':
        return super.activeModelSettings.presencePenalty;
      case 'repeatLastN':
        return super.activeModelSettings.repeatLastN;
      case 'repeatPenalty':
        return super.activeModelSettings.repeatPenalty;
      case 'seed':
        return super.activeModelSettings.seed;
      case 'stop':
        return super.activeModelSettings.stop;
      case 'tfsZ':
        return super.activeModelSettings.tfsZ;
      case 'topK':
        return super.activeModelSettings.topK;
      case 'topP':
        return super.activeModelSettings.topP;
      case 'typicalP':
        return super.activeModelSettings.typicalP;
      case 'useMlock':
        return super.activeModelSettings.useMlock;
      case 'useMmap':
        return super.activeModelSettings.useMmap;
      case 'vocabOnly':
        return super.activeModelSettings.vocabOnly;
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
  Future<void> set(String settingName, dynamic newValue) async {
    switch (settingName) {
      case 'systemPrompt':
        super.activeModelSettings.systemPrompt = newValue;
        break;
      case 'enableWebSearch':
        super.activeModelSettings.enableWebSearch = newValue;
        break;
      case 'enableDocsSearch':
        super.activeModelSettings.enableDocsSearch = newValue;
        break;
      case 'keepAlive':
        super.activeModelSettings.keepAlive = newValue;
        break;
      case 'temperature':
        super.activeModelSettings.temperature = newValue;
        break;
      case 'concurrencyLimit':
        super.activeModelSettings.concurrencyLimit = newValue;
        break;
      case 'f16KV':
        super.activeModelSettings.f16KV = newValue;
        break;
      case 'frequencyPenalty':
        super.activeModelSettings.frequencyPenalty = newValue;
        break;
      case 'logitsAll':
        super.activeModelSettings.logitsAll = newValue;
        break;
      case 'lowVram':
        super.activeModelSettings.lowVram = newValue;
        break;
      case 'numGpu':
        super.activeModelSettings.numGpu = newValue;
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
        super.activeModelSettings.mainGpu = newValue;
        break;
      case 'mirostat':
        super.activeModelSettings.mirostat = newValue;
        break;
      case 'mirostatEta':
        super.activeModelSettings.mirostatEta = newValue;
        break;
      case 'mirostatTau':
        super.activeModelSettings.mirostatTau = newValue;
        break;
      case 'numBatch':
        super.activeModelSettings.numBatch = newValue;
        break;
      case 'numCtx':
        super.activeModelSettings.numCtx = newValue;
        break;
      case 'numKeep':
        super.activeModelSettings.numKeep = newValue;
        break;
      case 'numPredict':
        super.activeModelSettings.numPredict = newValue;
        break;
      case 'numThread':
        super.activeModelSettings.numThread = newValue;
        break;
      case 'numa':
        super.activeModelSettings.numa = newValue;
        break;
      case 'penalizeNewline':
        super.activeModelSettings.penalizeNewline = newValue;
        break;
      case 'presencePenalty':
        super.activeModelSettings.presencePenalty = newValue;
        break;
      case 'repeatLastN':
        super.activeModelSettings.repeatLastN = newValue;
        break;
      case 'repeatPenalty':
        super.activeModelSettings.repeatPenalty = newValue;
        break;
      case 'seed':
        super.activeModelSettings.seed = newValue;
        break;
      case 'stop':
        super.activeModelSettings.stop = newValue;
        break;
      case 'tfsZ':
        super.activeModelSettings.tfsZ = newValue;
        break;
      case 'topK':
        super.activeModelSettings.topK = newValue;
        break;
      case 'topP':
        super.activeModelSettings.topP = newValue;
        break;
      case 'typicalP':
        super.activeModelSettings.typicalP = newValue;
        break;
      case 'useMlock':
        super.activeModelSettings.useMlock = newValue;
        break;
      case 'useMmap':
        super.activeModelSettings.useMmap = newValue;
        break;
      case 'vocabOnly':
        super.activeModelSettings.vocabOnly = newValue;
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
