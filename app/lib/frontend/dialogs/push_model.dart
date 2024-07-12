import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/models/ollama_responses.dart';
import 'package:open_local_ui/backend/providers/model.dart';
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
  int _completed = 0;
  int _total = 0;
  double _progressValue = 0.0;
  String _progressBarText = '';

  @override
  void dispose() {
    _modelSelectionController.dispose();
    super.dispose();
  }

  void _updateProgress(OllamaPushResponse response) {
    setState(() {
      _total = response.total;
      _completed = response.completed;
      _progressValue = response.completed / response.total;

      final duration = HTTPMethods.calculateRemainingTime(response);

      _progressBarText =
          AppLocalizations.of(context).progressBarStatusWithTimeText(
        response.status,
        (duration.inHours).toString(),
        (duration.inMinutes % 60).toString(),
        (duration.inSeconds % 60).toString(),
      );
    });
  }

  void _pushModel() async {
    setState(() => _isPushing = true);

    final stream = context
        .read<ModelProvider>()
        .push(_modelSelectionController.text.toLowerCase());

    await for (final data in stream) {
      if (mounted) _updateProgress(data);
    }

    if (mounted) {
      setState(() {
        _isPushing = false;
        _progressValue = 0.0;
        _progressBarText = '';
        _modelSelectionController.clear();
      });
    }
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
        AppLocalizations.of(context).pullModelDialogTitle,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_isPushing,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).pushModelDialogGuideText,
                ),
                const SizedBox(width: 8.0),
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
                      .pushModelDialogModelSelectorHint,
                  dropdownMenuEntries: modelsMenuEntries,
                  onSelected: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Visibility(
            visible: _isPushing,
            child: Column(
              children: [
                Text(_progressBarText),
                const Gap(8.0),
                LinearProgressIndicator(
                  value: _progressValue,
                  minHeight: 20.0,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                const Gap(8.0),
                Text(
                  '${_completed.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)} / ${_total.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)}',
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
            _isPushing
                ? AppLocalizations.of(context)
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context).dialogCloseButtonShared,
          ),
        ),
        if (!_isPushing)
          TextButton(
            onPressed: () => _pushModel(),
            child: Text(
              AppLocalizations.of(context).dialogStartButtonShared,
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

Future<void> showPushModelDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return const PushModelDialog();
    },
  );
}
