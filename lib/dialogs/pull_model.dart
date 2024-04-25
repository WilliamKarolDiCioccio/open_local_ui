import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:open_local_ui/helpers/http.dart';
import 'package:open_local_ui/models/ollama_responses.dart';
import 'package:open_local_ui/providers/model.dart';

class PullModelDialog extends StatefulWidget {
  const PullModelDialog({super.key});

  @override
  State<PullModelDialog> createState() => _PullModelDialogState();
}

class _PullModelDialogState extends State<PullModelDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isPulling = false;
  double _progressValue = 0.0;
  String _progressBarText = 'Preparing to pull model...';

  void _updateProgress(OllamaPullResponse response) {
    setState(() {
      _progressValue = response.completed / response.total;

      final duration = HTTPHelpers.calculateRemainingTime(response);

      _progressBarText =
          'Status: ${response.status} - Remaining time: ${duration.inHours}:${duration.inMinutes % 60}:${duration.inSeconds % 60}';
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pull model'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_isPulling,
            child: Column(
              children: [
                const Text('Please type the name of the model to pull:'),
                const SizedBox(width: 8.0),
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Model name',
                    hintText: 'Enter model name...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Visibility(
            visible: _isPulling,
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
          child: Text(_isPulling ? 'Continue in background' : 'Close'),
        ),
        if (!_isPulling)
          TextButton(
            onPressed: () async {
              setState(() => _isPulling = true);

              final stream = context
                  .read<ModelProvider>()
                  .pull(_textEditingController.text);

              await for (final response in stream) {
                if (context.mounted) _updateProgress(response);
              }

              if (context.mounted) {
                setState(() {
                  _isPulling = false;
                  _progressValue = 0.0;
                  _progressBarText = '';
                  _textEditingController.clear();
                });
              }
            },
            child: const Text('Start'),
          ),
      ],
    );
  }
}

Future<void> showPullModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const PullModelDialog();
    },
  );
}
