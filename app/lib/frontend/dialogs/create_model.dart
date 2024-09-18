import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/models/ollama_responses.dart';
import 'package:open_local_ui/backend/private/providers/model.dart';
import 'package:provider/provider.dart';

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
  final List<DropdownMenuEntry> _modelsMenuEntries = [];
  bool _isCreating = false;
  int _stepsCount = 0;
  double _progressValue = 0.0;
  String _progressBarText = '';

  @override
  void initState() {
    super.initState();

    for (final model in context.read<ModelProvider>().models) {
      final shortName = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;

      _modelsMenuEntries
          .add(DropdownMenuEntry(value: model.name, label: shortName));
    }
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _fileEditingController.dispose();
    _modelSelectionController.dispose();
    super.dispose();
  }

  void _updateProgress(OllamaCreateResponse response) {
    setState(() {
      _stepsCount += 1;

      _progressValue += _stepsCount / 11;

      _progressBarText =
          AppLocalizations.of(context).progressBarStatusWithStepsText(
        response.status,
        11,
        _stepsCount,
      );
    });
  }

  void _createModel() async {
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
          _nameEditingController.text.toLowerCase(),
          "FROM $modelBaseName\nSYSTEM ${_fileEditingController.text}",
        );

    await for (final data in stream) {
      if (mounted) _updateProgress(data);
    }

    if (mounted) {
      setState(() {
        _isCreating = false;
        _progressValue = 0.0;
        _progressBarText = '';
        _nameEditingController.clear();
        _fileEditingController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).createModelDialogTitle,
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
                  AppLocalizations.of(context).createModelDialogGuideText1,
                ),
                const Gap(8.0),
                DropdownMenu(
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
                  controller: _modelSelectionController,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  enableFilter: true,
                  enableSearch: true,
                  hintText: AppLocalizations.of(context)
                      .createModelDialogModelSelectorHint,
                  dropdownMenuEntries: _modelsMenuEntries,
                  onSelected: null,
                ),
                const SizedBox(height: 16.0),
                Text(
                  AppLocalizations.of(context).createModelDialogGuideText2,
                ),
                const Gap(8.0),
                TextField(
                  controller: _nameEditingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .createModelDialogModelNameLabel,
                    hintText: AppLocalizations.of(context)
                        .createModelDialogModelNameHint,
                  ),
                  maxLength: 32,
                  maxLines: 1,
                ),
                const Gap(16.0),
                Text(
                  AppLocalizations.of(context).createModelDialogGuideText3,
                ),
                const Gap(8.0),
                TextField(
                  controller: _fileEditingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .createModelDialogModelFileLabel,
                    hintText: AppLocalizations.of(context)
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
                  borderRadius: BorderRadius.circular(16.0),
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
                ? AppLocalizations.of(context)
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context).dialogCloseButtonShared,
          ),
        ),
        if (!_isCreating)
          TextButton(
            onPressed: () => _createModel(),
            child: Text(
              AppLocalizations.of(context).dialogCreateButtonShared,
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

Future<void> showCreateModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateModelDialog();
    },
  );
}
