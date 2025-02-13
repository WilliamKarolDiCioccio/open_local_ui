import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../generated/i18n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_local_ui/backend/private/models/ollama_responses.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:open_local_ui/core/http.dart';
import 'package:provider/provider.dart';
import 'package:units_converter/units_converter.dart';

class PullModelDialog extends StatefulWidget {
  final String modelName;
  final List<String> releases;

  const PullModelDialog({
    super.key,
    required this.modelName,
    required this.releases,
  });

  @override
  State<PullModelDialog> createState() => _PullModelDialogState();
}

class _PullModelDialogState extends State<PullModelDialog> {
  String? _selectedRelease;
  bool _isPulling = false;
  Stream<OllamaPullResponse>? _pullStream;

  @override
  void initState() {
    super.initState();

    // Add the latest release to the list of releases
    widget.releases.add('latest');

    if (widget.releases.isNotEmpty) {
      _selectedRelease = 'latest';
    }
  }

  void _pullModel() {
    final modelNameWithRelease = '${widget.modelName}:${_selectedRelease!}';

    setState(() {
      _isPulling = true;
      _pullStream = context
          .read<OllamaAPIProvider>()
          .pull(modelNameWithRelease.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).pullModelDialogTitle),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isPulling) ...[
            Text(AppLocalizations.of(context).pullModelDialogGuideText),
            const SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _selectedRelease,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRelease = newValue;
                });
              },
              items: widget.releases
                  .map<DropdownMenuItem<String>>((String release) {
                return DropdownMenuItem<String>(
                  value: release,
                  child: Text(release),
                );
              }).toList(),
              isExpanded: true,
            ),
          ] else ...[
            StreamBuilder<OllamaPullResponse>(
              stream: _pullStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isPulling = false;
                    });
                  });
                }

                if (snapshot.hasData) {
                  final response = snapshot.data!;
                  final total = response.total;
                  final completed = response.completed;
                  final progressValue = completed / total;
                  final duration = HTTPHelpers.calculateRemainingTime(response);
                  final fmt = NumberFormat('#00');
                  final progressBarText = AppLocalizations.of(context)
                      .progressBarStatusWithTimeText(
                    response.status,
                    fmt.format(duration.inHours),
                    fmt.format(duration.inMinutes % 60),
                    fmt.format(duration.inSeconds % 60),
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
                        '${completed.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)!.toStringAsFixed(2)} GB / ${total.convertFromTo(DIGITAL_DATA.byte, DIGITAL_DATA.gigabyte)!.toStringAsFixed(2)} GB',
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
            _isPulling
                ? AppLocalizations.of(context)
                    .dialogContinueInBackgroundButtonShared
                : AppLocalizations.of(context).dialogCloseButtonShared,
          ),
        ),
        if (!_isPulling)
          TextButton(
            onPressed: _selectedRelease != null ? _pullModel : null,
            child: Text(AppLocalizations.of(context).dialogStartButtonShared),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .move(begin: const Offset(0, 160), curve: Curves.easeOutQuad);
  }
}

Future<void> showPullModelDialog(
  BuildContext context,
  String modelName,
  List<String> releases,
) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return PullModelDialog(
        modelName: modelName,
        releases: releases,
      );
    },
  );
}
