import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:open_local_ui/models/ollama_responses.dart';
import 'package:open_local_ui/providers/model.dart';

class CreateModelDialog extends StatefulWidget {
  const CreateModelDialog({super.key});

  @override
  State<CreateModelDialog> createState() => _CreateModelDialogState();
}

class _CreateModelDialogState extends State<CreateModelDialog> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _fileEditingController = TextEditingController();
  final TextEditingController _modelSelectionController =
      TextEditingController();
  bool _isCreating = false;
  int _stepsCount = 0;
  double _progressValue = 0.0;
  String _progressBarText = '';

  void _updateProgress(OllamaCreateResponse response) {
    setState(() {
      _stepsCount += 1;

      _progressValue += _stepsCount / 11;

      _progressBarText =
          AppLocalizations.of(context)!.progressBarStatusTextWithStepsShared(
        response.status,
        11,
        _stepsCount,
      );
    });
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _fileEditingController.dispose();
    _modelSelectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> modelsMenuEntries = [];

    for (final model in context.read<ModelProvider>().models) {
      final shortName = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;

      modelsMenuEntries
          .add(DropdownMenuEntry(value: model.name, label: shortName));
    }

    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.createModelDialogTitle,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_isCreating,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.createModelDialogGuideText1,
                ),
                DropdownMenu(
                  controller: _modelSelectionController,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  enableFilter: true,
                  enableSearch: true,
                  hintText: AppLocalizations.of(context)!
                      .createModelDialogModelSelectorHint,
                  dropdownMenuEntries: modelsMenuEntries,
                  onSelected: null,
                ),
                const SizedBox(height: 16.0),
                Text(
                  AppLocalizations.of(context)!.createModelDialogGuideText2,
                ),
                TextField(
                  controller: _nameEditingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .createModelDialogModelNameLabel,
                    hintText: AppLocalizations.of(context)!
                        .createModelDialogModelNameHint,
                  ),
                  maxLength: 32,
                  maxLines: 1,
                ),
                const SizedBox(height: 16.0),
                Text(
                  AppLocalizations.of(context)!.createModelDialogGuideText3,
                ),
                TextField(
                  controller: _fileEditingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .createModelDialogModelFileLabel,
                    hintText: AppLocalizations.of(context)!
                        .createModelDialogModelFileHint,
                  ),
                  maxLength: 4096,
                  maxLines: null,
                  expands: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Visibility(
            visible: _isCreating,
            child: Column(
              children: [
                Text(_progressBarText),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: _progressValue,
                  minHeight: 20.0,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            _isCreating
                ? AppLocalizations.of(context)!
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context)!.dialogCloseButtonShared,
          ),
        ),
        if (!_isCreating)
          TextButton(
            onPressed: () async {
              setState(() => _isCreating = true);

              final splitIndex = _modelSelectionController.text.indexOf(':');
              String modelBaseName;

              if (splitIndex != -1) {
                modelBaseName = _modelSelectionController.text.substring(
                  0,
                  splitIndex,
                );
              } else {
                modelBaseName = _modelSelectionController.text;
              }

              final stream = context.read<ModelProvider>().create(
                    _nameEditingController.text,
                    "FROM $modelBaseName\nSYSTEM ${_fileEditingController.text}",
                  );

              await for (final data in stream) {
                if (context.mounted) _updateProgress(data);
              }

              if (context.mounted) {
                setState(() {
                  _isCreating = false;
                  _progressValue = 0.0;
                  _progressBarText = '';
                  _nameEditingController.clear();
                  _fileEditingController.clear();
                });
              }
            },
            child: Text(
              AppLocalizations.of(context)!.dialogCreateButtonShared,
            ),
          ),
      ],
    );
  }
}

Future<void> showCreateModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateModelDialog();
    },
  );
}
