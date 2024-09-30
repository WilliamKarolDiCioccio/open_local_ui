import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/models/ollama_responses.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:open_local_ui/core/http.dart';
import 'package:provider/provider.dart';
import 'package:units_converter/units_converter.dart';

class PushModelDialog extends StatefulWidget {
  const PushModelDialog({super.key});

  @override
  State<PushModelDialog> createState() => _PushModelDialogState();
}

class _PushModelDialogState extends State<PushModelDialog> {
  String? _selectedModel;
  final List<DropdownMenuItem<String>> _modelsMenuEntries = [];
  bool _isPushing = false;
  Stream<OllamaPushResponse>? _pushStream;

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

  void _pushModel() {
    setState(() {
      _isPushing = true;
      _pushStream =
          context.read<OllamaAPIProvider>().push(_selectedModel!.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).pushModelDialogTitle),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isPushing) ...[
            Text(AppLocalizations.of(context).pushModelDialogGuideText),
            const SizedBox(width: 8.0),
            DropdownButton<String>(
              value: _selectedModel,
              onChanged: (String? value) {
                setState(() {
                  _selectedModel = value;
                });
              },
              items: _modelsMenuEntries,
              isExpanded: true,
            ),
          ] else ...[
            StreamBuilder<OllamaPushResponse>(
              stream: _pushStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isPushing = false;
                    });
                  });
                }

                if (snapshot.hasData) {
                  final response = snapshot.data!;
                  final total = response.total;
                  final completed = response.completed;
                  final progressValue = completed / total;
                  final duration = HTTPHelpers.calculateRemainingTime(response);
                  final progressBarText = AppLocalizations.of(context)
                      .progressBarStatusWithTimeText(
                    response.status,
                    (duration.inHours).toString(),
                    (duration.inMinutes % 60).toString(),
                    (duration.inSeconds % 60).toString(),
                  );

                  return Column(
                    children: [
                      Text(progressBarText),
                      const Gap(8.0),
                      LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 20.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      const Gap(8.0),
                      Text(
                        '${completed.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)} / ${total.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)}',
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            _isPushing
                ? AppLocalizations.of(context)
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context).dialogCloseButtonShared,
          ),
        ),
        if (!_isPushing)
          TextButton(
            onPressed: _pushModel,
            child: Text(AppLocalizations.of(context).dialogStartButtonShared),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .move(begin: const Offset(0, 160), curve: Curves.easeOutQuad);
  }
}

Future<void> showPushModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return const PushModelDialog();
    },
  );
}
