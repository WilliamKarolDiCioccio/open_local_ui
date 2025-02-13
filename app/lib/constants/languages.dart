import 'package:flutter/material.dart';
import '../../generated/i18n/app_localizations.dart';

const languages = [
  Locale('en'), // English
  Locale('es'), // Spanish
  Locale('fr'), // French
  Locale('de'), // German
  Locale('it'), // Italian
  Locale('ja'), // Japanese
  Locale('ko'), // Korean
  Locale('pt'), // Portuguese
  Locale('ru'), // Russian
  Locale('zh'), // Chinese
  Locale('ar'), // Arabic
  Locale('hi'), // Hindi
];

final modelSettingsCategoryLabelsMap = {
  'modelGeneralSettingsLabel': (AppLocalizations loc) =>
      loc.modelGeneralSettingsLabel,
  'modelPerformanceSettingsLabel': (AppLocalizations loc) =>
      loc.modelPerformanceSettingsLabel,
  'modelPenaltySettingsLabel': (AppLocalizations loc) =>
      loc.modelPenaltySettingsLabel,
  'modelMiscSettingsLabel': (AppLocalizations loc) =>
      loc.modelMiscSettingsLabel,
};

final modelSettingsTooltipsMap = {
  'enableWebSearch': (AppLocalizations loc) => loc.tooltipEnableWebSearch,
  'enableDocsSearch': (AppLocalizations loc) => loc.tooltipEnableDocsSearch,
  'keepAlive': (AppLocalizations loc) => loc.tooltipKeepAlive,
  'temperature': (AppLocalizations loc) => loc.tooltipTemperature,
  'concurrencyLimit': (AppLocalizations loc) => loc.tooltipConcurrencyLimit,
  'lowVram': (AppLocalizations loc) => loc.tooltipLowVram,
  'numGpu': (AppLocalizations loc) => loc.tooltipNumGpu,
  'mainGpu': (AppLocalizations loc) => loc.tooltipMainGpu,
  'frequencyPenalty': (AppLocalizations loc) => loc.tooltipFrequencyPenalty,
  'penalizeNewline': (AppLocalizations loc) => loc.tooltipPenalizeNewline,
  'presencePenalty': (AppLocalizations loc) => loc.tooltipPresencePenalty,
  'repeatPenalty': (AppLocalizations loc) => loc.tooltipRepeatPenalty,
  'repeatLastN': (AppLocalizations loc) => loc.tooltipRepeatLastN,
  'f16KV': (AppLocalizations loc) => loc.tooltipF16KV,
  'logitsAll': (AppLocalizations loc) => loc.tooltipLogitsAll,
  'mirostat': (AppLocalizations loc) => loc.tooltipMirostat,
  'mirostatEta': (AppLocalizations loc) => loc.tooltipMirostatEta,
  'mirostatTau': (AppLocalizations loc) => loc.tooltipMirostatTau,
  'numBatch': (AppLocalizations loc) => loc.tooltipNumBatch,
  'numCtx': (AppLocalizations loc) => loc.tooltipNumCtx,
  'numKeep': (AppLocalizations loc) => loc.tooltipNumKeep,
  'numPredict': (AppLocalizations loc) => loc.tooltipNumPredict,
  'numThread': (AppLocalizations loc) => loc.tooltipNumThread,
  'numa': (AppLocalizations loc) => loc.tooltipNuma,
  'seed': (AppLocalizations loc) => loc.tooltipSeed,
  'tfsZ': (AppLocalizations loc) => loc.tooltipTfsZ,
  'topK': (AppLocalizations loc) => loc.tooltipTopK,
  'topP': (AppLocalizations loc) => loc.tooltipTopP,
  'typicalP': (AppLocalizations loc) => loc.tooltipTypicalP,
  'useMlock': (AppLocalizations loc) => loc.tooltipUseMlock,
  'useMmap': (AppLocalizations loc) => loc.tooltipUseMmap,
  'vocabOnly': (AppLocalizations loc) => loc.tooltipVocabOnly,
};
