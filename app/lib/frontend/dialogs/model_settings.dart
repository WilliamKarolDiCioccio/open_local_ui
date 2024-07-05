import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/models/model.dart';
import 'package:open_local_ui/backend/providers/model_settings.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ModelSettingsDialog extends StatefulWidget {
  final Model model;

  const ModelSettingsDialog({super.key, required this.model});

  @override
  ModelSettingsDialogState createState() => ModelSettingsDialogState();
}

class ModelSettingsDialogState extends State<ModelSettingsDialog> {
  late ModelSettings _settings;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late String modelName;

    if (widget.model.name.length > 20) {
      modelName = '${widget.model.name.substring(0, 20)}...';
    } else {
      modelName = widget.model.name;
    }

    return ChangeNotifierProvider(
      create: (context) => ModelSettingsProvider(widget.model.name),
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
              return const Center(child: CircularProgressIndicator());
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
                      title: Text(AppLocalizations.of(context)
                          .modelGeneralSettingsLabel),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              BoolSettingWidget(
                                label: AppLocalizations.of(context)
                                    .enableWebSearch,
                                setting: 'enableWebSearch',
                              ),
                              BoolSettingWidget(
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
                      title: Text(AppLocalizations.of(context)
                          .modelPerformanceSettingsLabel),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              IntSettingWidget(
                                label: AppLocalizations.of(context).keepAlive,
                                setting: 'keepAlive',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).temperature,
                                setting: 'temperature',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context)
                                    .concurrencyLimit,
                                setting: 'concurrencyLimit',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).lowVram,
                                setting: 'lowVram',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).mainGpu,
                                setting: 'mainGpu',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(AppLocalizations.of(context)
                          .modelPenaltySettingsLabel),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context)
                                    .frequencyPenalty,
                                setting: 'frequencyPenalty',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context)
                                    .penalizeNewline,
                                setting: 'penalizeNewline',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context)
                                    .presencePenalty,
                                setting: 'presencePenalty',
                              ),
                              DoubleSettingWidget(
                                label:
                                    AppLocalizations.of(context).repeatPenalty,
                                setting: 'repeatPenalty',
                              ),
                              IntSettingWidget(
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
                          AppLocalizations.of(context).modelMiscSettingsLabel),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: [
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).f16KV,
                                setting: 'f16KV',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).logitsAll,
                                setting: 'logitsAll',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).mirostat,
                                setting: 'mirostat',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).mirostatEta,
                                setting: 'mirostatEta',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).mirostatTau,
                                setting: 'mirostatTau',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).numBatch,
                                setting: 'numBatch',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).numCtx,
                                setting: 'numCtx',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).numKeep,
                                setting: 'numKeep',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).numPredict,
                                setting: 'numPredict',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).numThread,
                                setting: 'numThread',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).numa,
                                setting: 'numa',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).seed,
                                setting: 'seed',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).tfsZ,
                                setting: 'tfsZ',
                              ),
                              IntSettingWidget(
                                label: AppLocalizations.of(context).topK,
                                setting: 'topK',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).topP,
                                setting: 'topP',
                              ),
                              DoubleSettingWidget(
                                label: AppLocalizations.of(context).typicalP,
                                setting: 'typicalP',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).useMlock,
                                setting: 'useMlock',
                              ),
                              BoolSettingWidget(
                                label: AppLocalizations.of(context).useMmap,
                                setting: 'useMmap',
                              ),
                              BoolSettingWidget(
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

Future<void> showModelSettingsDialog(Model model, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelSettingsDialog(model: model);
    },
  );
}

class BoolSettingWidget extends StatelessWidget {
  final String label;
  final String setting;

  const BoolSettingWidget({
    super.key,
    required this.label,
    required this.setting,
  });

  @override
  Widget build(BuildContext context) {
    final modelSettings = context.watch<ModelSettingsProvider>();
    final value = modelSettings.get(setting) as bool?;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 250, child: Text(label)),
        DropdownMenu<bool?>(
          initialSelection: value,
          enableFilter: false,
          enableSearch: false,
          width: 150,
          menuHeight: 128,
          menuStyle: MenuStyle(
            elevation: WidgetStateProperty.all(
              8.0,
            ),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          dropdownMenuEntries: [
            DropdownMenuEntry<bool?>(
                value: null,
                label: AppLocalizations.of(context).settingsModelDefault),
            DropdownMenuEntry<bool?>(
                value: true,
                label: AppLocalizations.of(context).settingsModelOn),
            DropdownMenuEntry<bool?>(
                value: false,
                label: AppLocalizations.of(context).settingsModelOff),
          ],
          textStyle: TextStyle(
            color: switch (value) {
              null => null,
              true => Colors.green,
              false => Colors.red,
            },
            fontWeight: value == null ? FontWeight.normal : FontWeight.bold,
          ),
          onSelected: (bool? newValue) {
            context.read<ModelSettingsProvider>().set(setting, newValue);
          },
        ),
      ],
    );
  }
}

class IntSettingWidget extends StatefulWidget {
  final String label;
  final String setting;

  const IntSettingWidget({
    super.key,
    required this.label,
    required this.setting,
  });

  @override
  State<IntSettingWidget> createState() => _IntSettingWidgetState();
}

class _IntSettingWidgetState extends State<IntSettingWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    final modelSettings = context.read<ModelSettingsProvider>();
    final value = modelSettings.get(widget.setting);
    if (value != null) {
      _controller.text = modelSettings.get(widget.setting).toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onChanged: (value) {
              final newValue = int.tryParse(value);
              context.read<ModelSettingsProvider>().set(
                    widget.setting,
                    newValue,
                  );
            },
          ),
        ),
      ],
    );
  }
}

class DoubleSettingWidget extends StatefulWidget {
  final String label;
  final String setting;

  const DoubleSettingWidget({
    super.key,
    required this.label,
    required this.setting,
  });

  @override
  State<DoubleSettingWidget> createState() => _DoubleSettingWidgetState();
}

class _DoubleSettingWidgetState extends State<DoubleSettingWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    final modelSettings = context.read<ModelSettingsProvider>();
    final value = modelSettings.get(widget.setting);

    if (value != null) {
      _controller.text = modelSettings.get(widget.setting).toString();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onChanged: (value) {
              final newValue = double.tryParse(value);
              context.read<ModelSettingsProvider>().set(
                    widget.setting,
                    newValue,
                  );
            },
          ),
        ),
      ],
    );
  }
}
