import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/models/ollama_responses.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:provider/provider.dart';

class CreateModelDialog extends StatefulWidget {
  const CreateModelDialog({super.key});

  @override
  State<CreateModelDialog> createState() => _CreateModelDialogState();
}

class _CreateModelDialogState extends State<CreateModelDialog> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _fileEditingController = TextEditingController();
  String? _selectedModel;
  final List<DropdownMenuItem<String>> _modelsMenuEntries = [];
  bool _isCreating = false;
  int _stepsCount = 0;
  double _progressValue = 0.0;
  String _progressBarText = '';

  @override
  void initState() {
    super.initState();

    _modelsMenuEntries.addAll(
      context.read<OllamaAPIProvider>().models.map((model) {
        return DropdownMenuItem<String>(
          value: model.name,
          child: Text(model.name),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _fileEditingController.dispose();
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

    final stream = context.read<OllamaAPIProvider>().create(
          _nameEditingController.text.toLowerCase(),
          "FROM $_selectedModel\nSYSTEM ${_fileEditingController.text}",
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
                DropdownButton(
                  value: _selectedModel,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                  items: _modelsMenuEntries,
                  isExpanded: true,
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
