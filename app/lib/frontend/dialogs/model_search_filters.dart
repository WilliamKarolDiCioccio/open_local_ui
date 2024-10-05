import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';

class ModelSearchFilters {
  Set<String> selectedCapabilities = {};
  int maxSize = 512
      .convertFromTo(
        DIGITAL_DATA.gigabyte,
        DIGITAL_DATA.byte,
      )!
      .toInt();
  int minSize = 0;
  int maxResults = 255;
}

class ModelSearchFiltersDialog extends StatefulWidget {
  final ModelSearchFilters filters;

  const ModelSearchFiltersDialog({required this.filters, super.key});

  @override
  State<ModelSearchFiltersDialog> createState() =>
      _ModelSearchFiltersDialogState();
}

class _ModelSearchFiltersDialogState extends State<ModelSearchFiltersDialog> {
  ModelSearchFilters _filters = ModelSearchFilters();

  @override
  void initState() {
    super.initState();

    _filters.selectedCapabilities.addAll(widget.filters.selectedCapabilities);
    _filters.maxSize = widget.filters.maxSize;
    _filters.minSize = widget.filters.minSize;
    _filters.maxResults = widget.filters.maxResults;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).modelSearchFiltersDialogTitle),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(16),
          SegmentedButton<String>(
            emptySelectionAllowed: true,
            multiSelectionEnabled: true,
            selected: _filters.selectedCapabilities,
            segments: const [
              ButtonSegment(
                value: 'vision',
                label: Text('Vision'),
                icon: Icon(UniconsLine.eye),
              ),
              ButtonSegment(
                value: 'tools',
                label: Text('Tools'),
                icon: Icon(UniconsLine.drill),
              ),
              ButtonSegment(
                value: 'embedding',
                label: Text('Embedding'),
                icon: Icon(UniconsLine.layer_group),
              ),
              ButtonSegment(
                value: 'code',
                label: Text('Code'),
                icon: Icon(UniconsLine.brackets_curly),
              ),
            ],
            onSelectionChanged: (capabilities) {
              setState(() {
                _filters.selectedCapabilities.clear();
                _filters.selectedCapabilities.addAll(capabilities);
              });
            },
          ),
          const Gap(16),
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedMinSizeLabel(
              _filters.minSize
                  .convertFromTo(
                    DIGITAL_DATA.byte,
                    DIGITAL_DATA.gigabyte,
                  )!
                  .toStringAsFixed(2),
            ),
          ),
          const Gap(8),
          Slider(
            value: _filters.minSize.toDouble(),
            min: 0,
            max: 512.convertFromTo(
              DIGITAL_DATA.gigabyte,
              DIGITAL_DATA.byte,
            )!,
            onChanged: (value) {
              setState(() {
                _filters.minSize = value.toInt();
                _filters.minSize = _filters.minSize.clamp(0, _filters.maxSize);
              });
            },
          ),
          const Gap(16),
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedMaxSizeLabel(
              _filters.maxSize
                  .convertFromTo(
                    DIGITAL_DATA.byte,
                    DIGITAL_DATA.gigabyte,
                  )!
                  .toStringAsFixed(2),
            ),
          ),
          const Gap(8),
          Slider(
            value: _filters.maxSize.toDouble(),
            min: 0,
            max: 512.convertFromTo(
              DIGITAL_DATA.gigabyte,
              DIGITAL_DATA.byte,
            )!,
            onChanged: (value) {
              setState(() {
                _filters.maxSize = value.toInt();
                _filters.maxSize = 512
                    .convertFromTo(
                      DIGITAL_DATA.gigabyte,
                      DIGITAL_DATA.byte,
                    )!
                    .toInt()
                    .clamp(_filters.minSize, _filters.maxSize);
              });
            },
          ),
          const Gap(16),
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedMaxResultsLabel(
              _filters.maxResults,
            ),
          ),
          const Gap(8),
          Slider(
            value: _filters.maxResults.toDouble(),
            min: 1,
            max: 255,
            onChanged: (value) {
              setState(() {
                _filters.maxResults = value.toInt();
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          label: Text(
            AppLocalizations.of(context).resetToDefaultsButtonShared,
          ),
          icon: const Icon(UniconsLine.redo),
          onPressed: () => setState(() {
            _filters = ModelSearchFilters();
          }),
        ),
        TextButton.icon(
          label: Text(AppLocalizations.of(context).saveButtonShared),
          icon: const Icon(UniconsLine.save),
          onPressed: () => Navigator.of(context).pop(_filters),
        ),
      ],
    );
  }
}

Future<ModelSearchFilters?> showModelSearchFiltersDialog(
  BuildContext context,
  ModelSearchFilters filters,
) async {
  return showDialog<ModelSearchFilters>(
    context: context,
    builder: (context) {
      return ModelSearchFiltersDialog(filters: filters);
    },
  );
}
