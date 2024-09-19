import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/models/model.dart';
import 'package:open_local_ui/backend/private/providers/model.dart';
import 'package:open_local_ui/backend/private/providers/model_settings.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ModelSettingsDialog extends StatefulWidget {
  final String modelName;

  const ModelSettingsDialog({super.key, required this.modelName});

  @override
  ModelSettingsDialogState createState() => ModelSettingsDialogState();
}

class ModelSettingsDialogState extends State<ModelSettingsDialog> {
  late Model _model;
  late ModelSettings _settings;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _model = context.read<ModelProvider>().models.firstWhere(
          (model) => model.name == widget.modelName,
        );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late String modelName;

    if (_model.name.length > 20) {
      modelName = '${_model.name.substring(0, 20)}...';
    } else {
      modelName = _model.name;
    }

    return ChangeNotifierProvider(
      create: (context) => ModelSettingsProvider(_model.name),
      builder: (context, _) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)
              .modelSpecificSettingsDialogTitle(modelName),
          style: const TextStyle(fontSize: 24.0),
        ),
        content: FutureBuilder(
          future: context.read<ModelSettingsProvider>().load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: SpinKitCircle(
                  color: AdaptiveTheme.of(context).mode.isDark
                      ? Colors.white
                      : Colors.black,
                ),
              );
            }

            _settings = snapshot.data!;

            if (_settings.systemPrompt != null &&
                _settings.systemPrompt!.isNotEmpty) {
              _controller.text = _settings.systemPrompt!;
            } else {
              rootBundle.loadString('assets/prompts/default.txt').then(
                (value) {
                  _controller.text = value;
                },
              );
            }

            return SizedBox(
              width: 512,
              height: 512,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .systemPromptTextFieldLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onChanged: (value) async =>
                            await context.read<ModelSettingsProvider>().set(
                                  'systemPrompt',
                                  value,
                                ),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Neuton',
                          fontWeight: FontWeight.w300,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLength: TextField.noMaxLength,
                        maxLines: null,
                        expands: false,
                      ),
                    ),
                    const Gap(8.0),
                    const Divider(),
                    const Gap(8.0),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context).modelGeneralSettingsLabel,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context)
                                    .enableWebSearch,
                                setting: 'enableWebSearch',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context)
                                    .enableDocsSearch,
                                setting: 'enableDocsSearch',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context)
                            .modelPerformanceSettingsLabel,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).keepAlive,
                                setting: 'keepAlive',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).temperature,
                                setting: 'temperature',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context)
                                    .concurrencyLimit,
                                setting: 'concurrencyLimit',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).lowVram,
                                setting: 'lowVram',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).mainGpu,
                                setting: 'mainGpu',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context).modelPenaltySettingsLabel,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context)
                                    .frequencyPenalty,
                                setting: 'frequencyPenalty',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context)
                                    .penalizeNewline,
                                setting: 'penalizeNewline',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context)
                                    .presencePenalty,
                                setting: 'presencePenalty',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label:
                                    AppLocalizations.of(context).repeatPenalty,
                                setting: 'repeatPenalty',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).repeatLastN,
                                setting: 'repeatLastN',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.of(context).modelMiscSettingsLabel,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).f16KV,
                                setting: 'f16KV',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).logitsAll,
                                setting: 'logitsAll',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).mirostat,
                                setting: 'mirostat',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).mirostatEta,
                                setting: 'mirostatEta',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).mirostatTau,
                                setting: 'mirostatTau',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).numBatch,
                                setting: 'numBatch',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).numCtx,
                                setting: 'numCtx',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).numKeep,
                                setting: 'numKeep',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).numPredict,
                                setting: 'numPredict',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).numThread,
                                setting: 'numThread',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).numa,
                                setting: 'numa',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).seed,
                                setting: 'seed',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).tfsZ,
                                setting: 'tfsZ',
                              ),
                              SettingWidget(
                                type: SettingType.intSetting,
                                label: AppLocalizations.of(context).topK,
                                setting: 'topK',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).topP,
                                setting: 'topP',
                              ),
                              SettingWidget(
                                type: SettingType.doubleSetting,
                                label: AppLocalizations.of(context).typicalP,
                                setting: 'typicalP',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).useMlock,
                                setting: 'useMlock',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).useMmap,
                                setting: 'useMmap',
                              ),
                              SettingWidget(
                                type: SettingType.boolSetting,
                                label: AppLocalizations.of(context).vocabOnly,
                                setting: 'vocabOnly',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context).resetToDefaultsButton,
            ),
            icon: const Icon(
              UniconsLine.redo,
            ),
            onPressed: () {
              context.read<ModelSettingsProvider>().reset();
            },
          ),
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context).saveButtonShared,
            ),
            icon: const Icon(
              UniconsLine.save,
            ),
            onPressed: () {
              context.read<ModelSettingsProvider>().save();

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showModelSettingsDialog(
  String modelName,
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelSettingsDialog(modelName: modelName);
    },
  );
}

enum SettingType {
  boolSetting,
  intSetting,
  doubleSetting,
}

class SettingWidget extends StatefulWidget {
  final String label;
  final String setting;
  final SettingType type;

  const SettingWidget({
    super.key,
    required this.label,
    required this.setting,
    required this.type,
  });

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final modelSettings = context.read<ModelSettingsProvider>();
    final value = modelSettings.get(widget.setting);

    if (widget.type == SettingType.intSetting ||
        widget.type == SettingType.doubleSetting) {
      _controller = TextEditingController(text: value?.toString());
    } else {
      _controller = TextEditingController();
    }

    if (widget.type == SettingType.boolSetting && value != null) {
      _controller.text = value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelSettings = context.watch<ModelSettingsProvider>();
    final tooltipText = getTooltipText(widget.setting, context);

    switch (widget.type) {
      case SettingType.boolSetting:
        final bool? value = modelSettings.get(widget.setting) as bool?;
        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              DropdownButton<bool?>(
                value: value,
                onChanged: (bool? newValue) {
                  modelSettings.set(widget.setting, newValue);
                },
                items: [
                  DropdownMenuItem<bool?>(
                    value: null,
                    child:
                        Text(AppLocalizations.of(context).settingsModelDefault),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text(AppLocalizations.of(context).settingsModelOn),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text(AppLocalizations.of(context).settingsModelOff),
                  ),
                ],
              ),
            ],
          ),
        );

      case SettingType.intSetting:
        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              SizedBox(
                width: 150,
                child: TextField(
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = int.tryParse(value);
                    modelSettings.set(widget.setting, newValue);
                  },
                ),
              ),
            ],
          ),
        );

      case SettingType.doubleSetting:
        return Tooltip(
          message: tooltipText,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 250, child: Text(widget.label)),
              SizedBox(
                width: 150,
                child: TextField(
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    modelSettings.set(widget.setting, newValue);
                  },
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

String getTooltipText(String setting, BuildContext context) {
    switch (setting) {
      case 'enableWebSearch':
        return AppLocalizations.of(context).tooltipEnableWebSearch;
      case 'enableDocsSearch':
        return AppLocalizations.of(context).tooltipEnableDocsSearch;
      case 'keepAlive':
        return AppLocalizations.of(context).tooltipKeepAlive;
      case 'temperature':
        return AppLocalizations.of(context).tooltipTemperature;
      case 'concurrencyLimit':
        return AppLocalizations.of(context).tooltipConcurrencyLimit;
      case 'lowVram':
        return AppLocalizations.of(context).tooltipLowVram;
      case 'mainGpu':
        return AppLocalizations.of(context).tooltipMainGpu;
      case 'frequencyPenalty':
        return AppLocalizations.of(context).tooltipFrequencyPenalty;
      case 'penalizeNewline':
        return AppLocalizations.of(context).tooltipPenalizeNewline;
      case 'presencePenalty':
        return AppLocalizations.of(context).tooltipPresencePenalty;
      case 'repeatPenalty':
        return AppLocalizations.of(context).tooltipRepeatPenalty;
      case 'repeatLastN':
        return AppLocalizations.of(context).tooltipRepeatLastN;
      case 'f16KV':
        return AppLocalizations.of(context).tooltipF16KV;
      case 'logitsAll':
        return AppLocalizations.of(context).tooltipLogitsAll;
      case 'mirostat':
        return AppLocalizations.of(context).tooltipMirostat;
      case 'mirostatEta':
        return AppLocalizations.of(context).tooltipMirostatEta;
      case 'mirostatTau':
        return AppLocalizations.of(context).tooltipMirostatTau;
      case 'numBatch':
        return AppLocalizations.of(context).tooltipNumBatch;
      case 'numCtx':
        return AppLocalizations.of(context).tooltipNumCtx;
      case 'numKeep':
        return AppLocalizations.of(context).tooltipNumKeep;
      case 'numPredict':
        return AppLocalizations.of(context).tooltipNumPredict;
      case 'numThread':
        return AppLocalizations.of(context).tooltipNumThread;
      case 'numa':
        return AppLocalizations.of(context).tooltipNuma;
      case 'seed':
        return AppLocalizations.of(context).tooltipSeed;
      case 'tfsZ':
        return AppLocalizations.of(context).tooltipTfsZ;
      case 'topK':
        return AppLocalizations.of(context).tooltipTopK;
      case 'topP':
        return AppLocalizations.of(context).tooltipTopP;
      case 'typicalP':
        return AppLocalizations.of(context).tooltipTypicalP;
      case 'useMlock':
        return AppLocalizations.of(context).tooltipUseMlock;
      case 'useMmap':
        return AppLocalizations.of(context).tooltipUseMmap;
      case 'vocabOnly':
        return AppLocalizations.of(context).tooltipVocabOnly;
      default:
        return '';
    }
  }