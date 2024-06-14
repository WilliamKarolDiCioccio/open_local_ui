import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/models/ollama_responses.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ImportModelDialog extends StatefulWidget {
  const ImportModelDialog({super.key});

  @override
  State<ImportModelDialog> createState() => _ImportModelDialogState();
}

class _ImportModelDialogState extends State<ImportModelDialog> {
  File? _file;
  bool _isImporting = false;
  int _stepsCount = 0;
  double _progressValue = 0.0;
  String _progressBarText = '';

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: false,
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );

    if (result != null) {
      _file = File(result.files.single.path!);
    }

    setState(() {});
  }

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

  void _importModel() async {
    setState(() => _isImporting = true);

    // ignore: use_build_context_synchronously
    final stream = context.read<ModelProvider>().create(
          path.basenameWithoutExtension(_file!.path).toLowerCase(),
          'FROM "${_file!.path}"',
        );

    await for (final data in stream) {
      if (context.mounted) _updateProgress(data);
    }

    if (context.mounted) {
      setState(() {
        _isImporting = false;
        _progressValue = 0.0;
        _progressBarText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.importModelDialogTitle,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              if (_file != null)
                Text(
                  path.basename(_file!.path),
                  style: const TextStyle(fontSize: 16.0),
                ),
              if (_file != null) const Gap(8.0),
              if (!_isImporting)
                TextButton.icon(
                  label: Text(
                    AppLocalizations.of(context)!
                        .attachFilesDialogBrowseFilesButton,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  icon: const Icon(UniconsLine.folder),
                  onPressed: () => _selectFile(),
                ),
              if (!_isImporting)
                Text(
                  AppLocalizations.of(context)!
                      .attachFilesDialogAllowedFormatsText(
                    'GGUF',
                  ),
                  style: const TextStyle(fontSize: 14.0),
                ),
            ],
          ),
          Visibility(
            visible: _isImporting,
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
            _isImporting
                ? AppLocalizations.of(context)!
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context)!.dialogCloseButtonShared,
          ),
        ),
        if (!_isImporting && _file != null)
          TextButton(
            onPressed: () => _importModel(),
            child: Text(
              AppLocalizations.of(context)!.modelsPageImportButton,
            ),
          ),
      ],
    );
  }
}

Future<void> showImportModelDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ImportModelDialog();
    },
  );
}
