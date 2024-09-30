import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';

class ModelSearchFilters {
  Set<String> selectedCapabilities = {};
  double maxSize = 512;
  double minSize = 0;
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
  final _filters = ModelSearchFilters();

  @override
  void initState() {
    super.initState();

    _filters.selectedCapabilities.addAll(widget.filters.selectedCapabilities);
    _filters.maxSize = widget.filters.maxSize;
    _filters.minSize = widget.filters.minSize;
    _filters.maxResults = widget.filters.maxResults;
  }

  double linearToExponential(double value) {
    return value <= 0 ? 0 : pow(value, 1.5).toDouble();
  }

  double exponentialToLinear(double value) {
    return pow(value, 1 / 1.5).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Filters'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Text('Minimum size: ${_filters.minSize.convertFromTo(
                DIGITAL_DATA.byte,
                DIGITAL_DATA.gigabyte,
              )!.toStringAsFixed(2)} GB'),
          const Gap(8),
          Slider(
            value: linearToExponential(_filters.minSize),
            min: 0,
            max: linearToExponential(
              512.convertFromTo(
                DIGITAL_DATA.gigabyte,
                DIGITAL_DATA.byte,
              )!,
            ),
            onChanged: (value) {
              setState(() {
                _filters.minSize = exponentialToLinear(value);
                _filters.minSize =
                    clampDouble(_filters.minSize, 0, _filters.maxSize);
              });
            },
          ),
          const Gap(16),
          Text('Max size: ${_filters.maxSize.convertFromTo(
                DIGITAL_DATA.byte,
                DIGITAL_DATA.gigabyte,
              )!.toStringAsFixed(2)} GB'),
          const Gap(8),
          Slider(
            value: linearToExponential(_filters.maxSize),
            min: 0,
            max: linearToExponential(
              512.convertFromTo(
                DIGITAL_DATA.gigabyte,
                DIGITAL_DATA.byte,
              )!,
            ),
            onChanged: (value) {
              setState(() {
                _filters.maxSize = exponentialToLinear(value);
                _filters.maxSize = clampDouble(
                  _filters.maxSize,
                  _filters.minSize,
                  512.convertFromTo(
                    DIGITAL_DATA.gigabyte,
                    DIGITAL_DATA.byte,
                  )!,
                );
              });
            },
          ),
          const Gap(16),
          Text('Max results: ${_filters.maxResults.toString()}'),
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_filters);
          },
          child: const Text('Save'),
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
