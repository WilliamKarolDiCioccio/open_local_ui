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
  final TextEditingController _modelSelectionController =
      TextEditingController();
  bool _isPushing = false;
  Stream<OllamaPushResponse>? _pushStream;

  @override
  void dispose() {
    _modelSelectionController.dispose();
    super.dispose();
  }

  void _pushModel() {
    setState(() {
      _isPushing = true;
      _pushStream = context
          .read<OllamaAPIProvider>()
          .push(_modelSelectionController.text.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> modelsMenuEntries =
        context.read<OllamaAPIProvider>().models.map((model) {
      final shortName = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;
      return DropdownMenuEntry(value: model.name, label: shortName);
    }).toList();

    return AlertDialog(
      title: Text(AppLocalizations.of(context).pullModelDialogTitle),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isPushing) ...[
            Text(AppLocalizations.of(context).pushModelDialogGuideText),
            const SizedBox(width: 8.0),
            DropdownMenu(
              menuHeight: 128,
              menuStyle: MenuStyle(
                elevation: WidgetStateProperty.all(8.0),
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
              hintText:
                  AppLocalizations.of(context).pushModelDialogModelSelectorHint,
              dropdownMenuEntries: modelsMenuEntries,
              onSelected: null,
            ),
          ] else ...[
            StreamBuilder<OllamaPushResponse>(
              stream: _pushStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isPushing = false;
                      _modelSelectionController.clear();
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
