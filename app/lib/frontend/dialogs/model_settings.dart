import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/models/model.dart';
import 'package:open_local_ui/backend/providers/model_settings.dart';
import 'package:provider/provider.dart';

class ModelSettings extends StatefulWidget {
  final Model model;

  const ModelSettings({super.key, required this.model});

  @override
  ModelSettingsState createState() => ModelSettingsState();
}

class ModelSettingsState extends State<ModelSettings> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModelSettingsProvider(widget.model.name),
      builder: (context, _) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).settingsModelDialogTitle(widget.model.name),
          style: const TextStyle(fontSize: 24.0),
        ),
        content: FutureBuilder(
          future: context.read<ModelSettingsProvider>().loadSettings(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            _controller.text = snapshot.data.toString();

            return SizedBox(
              width: 512,
              height: 512,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExpansionTile(
                      title: Text(AppLocalizations.of(context).modelGeneralSettingsLabel),
                      children: const [
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          children: [
                            BoolSettingWidget(
                              label: 'Websearch:',
                              setting: 'enableWebSearch',
                            ),
                            BoolSettingWidget(
                              label: 'Doc Search:',
                              setting: 'enableDocSearch',
                            ),
                            BoolSettingWidget(
                              label: 'Image Upload:',
                              setting: 'enableImages',
                            ),
                            BoolSettingWidget(
                              label: 'Statistics in chat:',
                              setting: 'showStatistics',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(16.0),
                    ExpansionTile(
                      title: Text(AppLocalizations.of(context).modelPerformanceSettingsLabel),
                      children: const [
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          children: [
                            IntSettingWidget(
                              label: 'Keep Alive:',
                              setting: 'keepAlive',
                            ),
                            DoubleSettingWidget(
                              label: 'Temperature:',
                              setting: 'temperature',
                            ),
                            IntSettingWidget(
                              label: 'Concurrency Limit:',
                              setting: 'concurrencyLimit',
                            ),
                            BoolSettingWidget(
                              label: 'Low VRAM:',
                              setting: 'lowVram',
                            ),
                            IntSettingWidget(
                              label: 'Main GPU:',
                              setting: 'mainGpu',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(16.0),
                    ExpansionTile(
                      title: Text(AppLocalizations.of(context).modelPenaltySettingsLabel),
                      children: const [
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          children: [
                            DoubleSettingWidget(
                              label: 'Frequency Penalty:',
                              setting: 'frequencyPenalty',
                            ),
                            BoolSettingWidget(
                              label: 'Penalize Newline:',
                              setting: 'penalizeNewline',
                            ),
                            DoubleSettingWidget(
                              label: 'Presence Penalty:',
                              setting: 'presencePenalty',
                            ),
                            DoubleSettingWidget(
                              label: 'Repeat Penalty:',
                              setting: 'repeatPenalty',
                            ),
                            IntSettingWidget(
                              label: 'Repeat Last N:',
                              setting: 'repeatLastN',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(16.0),
                    ExpansionTile(
                      title: Text(AppLocalizations.of(context).modelMiscSettingsLabel),
                      children: const [
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          children: [
                            BoolSettingWidget(
                              label: 'F16KV:',
                              setting: 'f16KV',
                            ),
                            BoolSettingWidget(
                              label: 'Logits All:',
                              setting: 'logitsAll',
                            ),
                            IntSettingWidget(
                              label: 'Microstat:',
                              setting: 'mirostat',
                            ),
                            DoubleSettingWidget(
                              label: 'Microstat ETA:',
                              setting: 'mirostatEta',
                            ),
                            DoubleSettingWidget(
                              label: 'Microstat TAU:',
                              setting: 'mirostatTau',
                            ),
                            IntSettingWidget(
                              label: 'Num. Batch:',
                              setting: 'numBatch',
                            ),
                            IntSettingWidget(
                              label: 'Context Window Size:',
                              setting: 'numCtx',
                            ),
                            IntSettingWidget(
                              label: 'Num. Keep:',
                              setting: 'numKeep',
                            ),
                            IntSettingWidget(
                              label: 'Num. Predict:',
                              setting: 'numPredict',
                            ),
                            IntSettingWidget(
                              label: 'Num. Threads:',
                              setting: 'numThread',
                            ),
                            BoolSettingWidget(
                              label: 'NUMA:',
                              setting: 'numa',
                            ),
                            IntSettingWidget(
                              label: 'Seed:',
                              setting: 'seed',
                            ),
                            DoubleSettingWidget(
                              label: 'tfsZ:',
                              setting: 'tfsZ',
                            ),
                            IntSettingWidget(
                              label: 'topK:',
                              setting: 'topK',
                            ),
                            DoubleSettingWidget(
                              label: 'topP:',
                              setting: 'topP',
                            ),
                            DoubleSettingWidget(
                              label: 'typicalP:',
                              setting: 'typicalP',
                            ),
                            BoolSettingWidget(
                              label: 'Use Mlock:',
                              setting: 'useMlock',
                            ),
                            BoolSettingWidget(
                              label: 'Use Mmap:',
                              setting: 'useMmap',
                            ),
                            BoolSettingWidget(
                              label: 'Vocab Only:',
                              setting: 'vocabOnly',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> showModelSettingsDialog(Model model, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelSettings(model: model);
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
              onSubmitted: (value) {
                final newValue = int.tryParse(value);
                context
                    .read<ModelSettingsProvider>()
                    .set(widget.setting, newValue);
              },
            )),
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
              onSubmitted: (value) {
                final newValue = double.tryParse(value);
                context
                    .read<ModelSettingsProvider>()
                    .set(widget.setting, newValue);
              },
            )),
      ],
    );
  }
}
