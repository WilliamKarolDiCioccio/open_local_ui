import 'dart:convert';
import 'dart:io';

import 'package:open_local_ui/core/models/model.dart';
import 'package:path_provider/path_provider.dart';

/// A service class for managing model settings within a Flutter app.
///
/// This class is used to load, save, and manage settings for a model.
class ModelSettingsService {
  final String modelName;
  late String activeProfileName;
  final Map<String, ModelSettings> _modelSettingsMap;

  /// Default initializations for late variables are provided in the constructor because the [_init] method runs asynchronously and there is no way to await it in the constructor.
  ModelSettingsService(this.modelName)
    : activeProfileName = 'default',
      _modelSettingsMap = {};

  /// Called when the provider is initialized from [ModelSettingsDialog]. It preloads the settings from the profile associations file.
  /// Calling this in the constructor prevents late initialization errors.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are preloaded.
  Future<void> preloadSettings() async {
    if (modelName.isEmpty) {
      throw ArgumentError('Model name cannot be empty');
    }

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
      activeProfileName = profileAssociations[modelName];
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

    if (!_modelSettingsMap.containsKey(activeProfileName)) {
      throw ArgumentError('Active profile does not exist');
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
      await file.writeAsString(jsonEncode(ModelSettings.fromJson({}).toJson()));
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

    final file = File('${dir.path}/models_profiles/profiles_associations.json');

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    if (await file.length() == 0) {
      await file.writeAsString('{}');
    }

    return file;
  }

  /// Returns the active profile name for the given model.
  Future<String> getAssociatedProfileName() async {
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
    if (profileName == null) return _modelSettingsMap[activeProfileName]!;

    final profileAssociationsFile = await _getProfileAssociationsFile();
    final profileAssociations = jsonDecode(
      await profileAssociationsFile.readAsString(),
    );

    profileAssociations[modelName] = profileName;
    profileAssociationsFile.writeAsStringSync(jsonEncode(profileAssociations));

    activeProfileName = profileName;
    _modelSettingsMap[profileName] ??= await loadProfile(profileName);

    return _modelSettingsMap[profileName]!;
  }

  /// Loads the given settings profile file. It does not update the active profile.
  /// If the profile does not exist, it returns an empty settings object.
  ///
  /// Returns the a [ModelSettings] object.
  Future<ModelSettings> loadProfile(String? profileName) async {
    profileName ??= activeProfileName;

    final settingsFile = await getModelSettingsProfileFile(
      modelName,
      profileName,
    );

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
    profileName ??= activeProfileName;

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
  ///
  /// If the [profileName] parameter is `null`, it resets the active profile.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are reset.
  Future<void> resetProfile(String? profileName) async {
    profileName ??= activeProfileName;

    final settingsFile = await getModelSettingsProfileFile(
      modelName,
      profileName,
    );

    await settingsFile.writeAsString(jsonEncode(<String, dynamic>{}));

    _modelSettingsMap[profileName] = ModelSettings.fromJson({});
    await loadProfile(profileName);
  }

  /// Removes the settings file for the given model.
  ///
  /// If the [profileName] parameter is `null`, it removes the active profile.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are removed.
  Future<void> removeProfile(String? profileName) async {
    profileName ??= activeProfileName;

    final settingsFile = await getModelSettingsProfileFile(
      modelName,
      profileName,
    );
    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }

    _modelSettingsMap.remove(profileName);
  }

  /// Removes all profiles for the model.
  ///
  /// Returns a [Future] that evaluates to `void` when the settings are removed.
  ///
  /// This method also clears the model settings map.
  Future<void> removeAllProfiles() async {
    final dir = await getApplicationSupportDirectory();

    final cleanModelName = modelName
        .toLowerCase()
        .replaceAll(RegExp(r'\W'), '_')
        .replaceAll(RegExp(r'_latest$'), '')
        .toLowerCase();

    final profilesDir = Directory(
      '${dir.path}/models_profiles/$cleanModelName',
    );

    if (await profilesDir.exists()) {
      await profilesDir.delete(recursive: true);
    }

    _modelSettingsMap.clear();
  }

  /// Returns the active model settings.
  ModelSettings get activeModelSettings =>
      _modelSettingsMap[activeProfileName]!;

  /// Returns the map of all model settings.
  Map<String, ModelSettings> get modelSettingsMap => _modelSettingsMap;

  /// Sets the active model settings.
  set activeModelSettings(ModelSettings settings) {
    _modelSettingsMap[activeProfileName] = settings;
  }
}
