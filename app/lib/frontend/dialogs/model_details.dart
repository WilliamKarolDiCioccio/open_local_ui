import 'package:flutter/material.dart';

import 'package:conversion_units/conversion_units.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/backend/models/model.dart';
import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/backend/providers/model_settings.dart';
import 'package:provider/provider.dart';

class ModelDetailsDialog extends StatelessWidget {
  final Model model;

  const ModelDetailsDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(model.name),
      content: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).modifiedAtTextShared(
              model.modifiedAt.toString(),
            ),
          ),
          Text(
            AppLocalizations.of(context).modelDetailsSizeText(
              Kilobytes.toGigabytes(model.size.toDouble() / 1024)
                  .toStringAsFixed(1),
            ),
          ),
          Text(
            AppLocalizations.of(context).modelDetailsDigestText(model.digest),
          ),
          Text(
            AppLocalizations.of(context)
                .modelDetailsFormatText(model.details.format),
          ),
          Text(
            AppLocalizations.of(context)
                .modelDetailsFamilyText(model.details.family),
          ),
          if (model.details.families != null)
            Text(
              AppLocalizations.of(context).modelDetailsFamilyText(
                model.details.families!.join(', '),
              ),
            ),
          Text(
            AppLocalizations.of(context)
                .modelDetailsParametersSizeText(model.details.parameterSize),
          ),
          Text(
            AppLocalizations.of(context).modelDetailsQuantizationLevelText(
              model.details.quantizationLevel.toString(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).settingsModelTitle,
            style: const TextStyle(fontSize: 24.0),
          ),
          ModelSettings(model: model),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // As we might have changed the currently used model we reload that one too.
            context.read<ChatProvider>().loadSettings();
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context).closeButtonShared,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: 200.ms,
        )
        .move(
          begin: const Offset(0, 160),
          curve: Curves.easeOutQuad,
        );
  }
}

Future<void> showModelDetailsDialog(Model model, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ModelDetailsDialog(model: model);
    },
  );
}

class ModelSettings extends StatefulWidget {
  final Model model;

  const ModelSettings({super.key, required this.model});

  @override
  ModelSettingsState createState() => ModelSettingsState();
}

class ModelSettingsState extends State<ModelSettings> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelSettingsProvider>(
      create: (context) => ModelSettingsProvider(widget.model.name),
      builder: (context, _) => FutureBuilder(
        future: context.read<ModelSettingsProvider>().loadSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                    label: 'F16KV:',
                    setting: 'f16KV',
                  ),
                  DoubleSettingWidget(
                    label: 'Frequency Penalty:',
                    setting: 'frequencyPenalty',
                  ),
                  BoolSettingWidget(
                    label: 'Logits All:',
                    setting: 'logitsAll',
                  ),
                  BoolSettingWidget(
                    label: 'Low VRAM:',
                    setting: 'lowVram',
                  ),
                  IntSettingWidget(
                    label: 'Main GPU:',
                    setting: 'mainGpu',
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
                  BoolSettingWidget(
                    label: 'Penalize Newline:',
                    setting: 'penalizeNewline',
                  ),
                  DoubleSettingWidget(
                    label: 'Presence Penalty:',
                    setting: 'presencePenalty',
                  ),
                  IntSettingWidget(
                    label: 'Repeat Last N:',
                    setting: 'repeatLastN',
                  ),
                  DoubleSettingWidget(
                    label: 'Repeat Penalty:',
                    setting: 'repeatPenalty',
                  ),
                  IntSettingWidget(
                    label: 'Seed:',
                    setting: 'seed',
                  ),
                  IntSettingWidget(
                    label: 'Stop List:',
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
            ),
          );
        },
      ),
    );
  }
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
