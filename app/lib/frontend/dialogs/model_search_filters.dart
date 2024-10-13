import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';

class ModelSearchFilters {
  Set<String> order = {'name'};
  Set<String> sort = {'ascending'};
  Set<String> capabilities = {};
  int maxSize = 512
      .convertFromTo(
        DIGITAL_DATA.gigabyte,
        DIGITAL_DATA.byte,
      )!
      .toInt();
  int minSize = 0;
  int maxResults = 255;

  ModelSearchFilters fromSharedPreferences(SharedPreferences prefs) {
    final order = prefs.getString('model_search_filters_order') ?? 'name';
    final sort = prefs.getString('model_search_filters_sort') ?? 'ascending';
    final capabilities =
        prefs.getStringList('model_search_filters_capabilities') ?? [];
    final maxSize = prefs.getInt('model_search_filters_max_size') ??
        512
            .convertFromTo(
              DIGITAL_DATA.gigabyte,
              DIGITAL_DATA.byte,
            )!
            .toInt();
    final minSize = prefs.getInt('model_search_filters_min_size') ?? 0;
    final maxResults = prefs.getInt('model_search_filters_max_results') ?? 255;

    this.order.clear();
    this.order.add(order);
    this.sort.clear();
    this.sort.add(sort);
    this.capabilities.addAll(capabilities);
    this.maxSize = maxSize;
    this.minSize = minSize;
    this.maxResults = maxResults;

    return this;
  }

  void toSharedPreferences(SharedPreferences prefs) {
    prefs.setString(
      'model_search_filters_order',
      order.first,
    );
    prefs.setString(
      'model_search_filters_sort',
      sort.first,
    );
    prefs.setStringList(
      'model_search_filters_capabilities',
      capabilities.toList(),
    );
    prefs.setInt('model_search_filters_max_size', maxSize);
    prefs.setInt('model_search_filters_min_size', minSize);
    prefs.setInt('model_search_filters_max_results', maxResults);
  }
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

    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _filters = widget.filters.fromSharedPreferences(prefs);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).modelSearchFiltersDialogTitle),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedOrderLabel,
          ),
          const Gap(8),
          SegmentedButton<String>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            selected: _filters.order,
            segments: [
              ButtonSegment(
                value: 'name',
                label: Text(
                  AppLocalizations.of(context).sortByNameOption,
                ),
                icon: const Icon(UniconsLine.tag),
              ),
              ButtonSegment(
                value: 'size',
                label: Text(
                  AppLocalizations.of(context).sortBySizeOption,
                ),
                icon: const Icon(UniconsLine.database),
              ),
              ButtonSegment(
                enabled: false,
                value: 'popularity',
                label: Text(
                  AppLocalizations.of(context).sortByPopularityOption,
                ),
                icon: const Icon(UniconsLine.star),
              ),
            ],
            onSelectionChanged: (order) {
              setState(() {
                _filters.order.clear();
                _filters.order.addAll(order);
              });
            },
          ),
          const Gap(16),
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedSortLabel,
          ),
          const Gap(8),
          SegmentedButton<String>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            selected: _filters.sort,
            segments: [
              ButtonSegment(
                value: 'ascending',
                label: Text(
                  AppLocalizations.of(context).sortOrderAscendingOption,
                ),
                icon: const Icon(UniconsLine.sort_amount_up),
              ),
              ButtonSegment(
                value: 'descending',
                label: Text(
                  AppLocalizations.of(context).sortOrderDescendingOption,
                ),
                icon: const Icon(UniconsLine.sort_amount_down),
              ),
            ],
            onSelectionChanged: (sort) {
              setState(() {
                _filters.sort.clear();
                _filters.sort.addAll(sort);
              });
            },
          ),
          const Gap(16),
          Text(
            AppLocalizations.of(context)
                .modelSearchFiltersDialogSelectedCapabilitiesLabel,
          ),
          const Gap(8),
          SegmentedButton<String>(
            emptySelectionAllowed: true,
            multiSelectionEnabled: true,
            selected: _filters.capabilities,
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
                _filters.capabilities.clear();
                _filters.capabilities.addAll(capabilities);
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
          onPressed: () {
            SharedPreferences.getInstance().then((prefs) {
              widget.filters.toSharedPreferences(prefs);
            });

            Navigator.of(context).pop(_filters);
          },
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
