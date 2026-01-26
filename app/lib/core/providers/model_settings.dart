// ignore_for_file: unnecessary_getters_setters

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:open_local_ui/core/constants/constants.dart';
import 'package:open_local_ui/core/models/model.dart';
import 'package:open_local_ui/core/services/model_settings.dart';
import 'package:open_local_ui/core/utils/snackbar.dart';
import 'package:open_local_ui/localization/app_localizations.dart';

/// A provider class for managing model settings within a Flutter app.
///
/// Extends [ModelSettingsService] and adds [ChangeNotifier] to notify listeners when settings are changed.
class ModelSettingsProvider extends ModelSettingsService with ChangeNotifier {
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
          SnackbarUtils.showSnackBar(
            AppLocalizations.of(
              scaffoldMessengerKey.currentContext!,
            ).snackBarWarningTitle,
            AppLocalizations.of(
              scaffoldMessengerKey.currentContext!,
            ).ollamaDisabledGPUWarningSnackBar,
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
