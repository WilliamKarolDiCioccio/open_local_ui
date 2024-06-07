import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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
  String _progressBarText = '';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _updateProgress(OllamaPullResponse response) {
    setState(() {
      _progressValue = response.completed / response.total;

      final duration = HTTPHelpers.calculateRemainingTime(response);

      final fmt = NumberFormat('#00');

      _progressBarText =
          AppLocalizations.of(context)!.progressBarStatusTextWithTimeShared(
        response.status,
        fmt.format(duration.inHours),
        fmt.format(duration.inMinutes % 60),
        fmt.format(duration.inSeconds % 60),
      );
    });
  }

  void _pullModel() async {
    setState(() => _isPulling = true);

    final stream = context
        .read<ModelProvider>()
        .pull(_textEditingController.text.toLowerCase());

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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.pullModelDialogTitle,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_isPulling,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.pullModelDialogGuideText1,
                ),
                const SizedBox(width: 8.0),
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .pullModelDialogModelNameLabel,
                    hintText: AppLocalizations.of(context)!
                        .pullModelDialogModelNameHint,
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
            _isPulling
                ? AppLocalizations.of(context)!
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context)!.dialogCloseButtonShared,
          ),
        ),
        if (!_isPulling)
          TextButton(
            onPressed: () => _pullModel(),
            child: Text(
              AppLocalizations.of(context)!.dialogStartButtonShared,
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

Future<void> showPullModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const PullModelDialog();
    },
  );
}
