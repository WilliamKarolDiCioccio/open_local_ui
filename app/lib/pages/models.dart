import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/dialogs/confirmation.dart';
import 'package:open_local_ui/dialogs/create_model.dart';
import 'package:open_local_ui/dialogs/import_model.dart';
import 'package:open_local_ui/dialogs/model_details.dart';
import 'package:open_local_ui/dialogs/pull_model.dart';
import 'package:open_local_ui/dialogs/push_model.dart';
import 'package:open_local_ui/helpers/datetime.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/dashboard.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/model.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

enum SortBy {
  name,
  date,
  size,
}

enum SortOrder {
  ascending,
  descending,
}

class ModelsPage extends StatefulWidget {
  final PageController pageController;

  const ModelsPage({super.key, required this.pageController});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  late Set<SortBy> _sortBy;
  late Set<SortOrder> _sortOrder;

  final prototypeModel = Model(
    name: '',
    modifiedAt: DateTime.timestamp(),
    size: 0,
    digest: '',
    details: ModelDetails(
      format: '',
      family: '',
      families: [],
      parameterSize: '',
      quantizationLevel: '',
    ),
  );

  @override
  void initState() {
    super.initState();

    _sortBy = {SortBy.name};
    _sortOrder = {SortOrder.ascending};

    SharedPreferences.getInstance().then((prefs) {
      final sortBy = prefs.getInt('modelsSortBy') ?? 0;
      final sortOrder = prefs.getBool('modelsSortOrder') ?? false;

      setState(() {
        _sortBy = {SortBy.values[sortBy]};
        _sortOrder = {sortOrder ? SortOrder.descending : SortOrder.ascending};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var sortedModels = context.watch<ModelProvider>().models;

    sortedModels.sort(
      (a, b) {
        if (_sortBy.contains(SortBy.name)) {
          return a.name.compareTo(b.name);
        } else if (_sortBy.contains(SortBy.date)) {
          return a.modifiedAt.compareTo(
            b.modifiedAt,
          );
        } else if (_sortBy.contains(SortBy.size)) {
          return a.size.compareTo(b.size);
        }
        return 0;
      },
    );

    if (_sortOrder.contains(SortOrder.descending)) {
      sortedModels = sortedModels.reversed.toList();
    }

    return PageBaseLayout(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.modelsPageTitle,
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.modelsPagePullButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.download_alt),
                onPressed: () => showPullModelDialog(context),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.modelsPagePushButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.upload_alt),
                onPressed: () => showPushModelDialog(context),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.modelsPageCreateButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.create_dashboard),
                onPressed: () => showCreateModelDialog(context),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.modelsPageImportButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.cube),
                onPressed: () => showImportModelDialog(context),
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.of(context)!.modelsPageRefreshButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.sync),
                onPressed: () {
                  context.read<ModelProvider>().updateList();
                },
              ),
            ],
          ),
          const Gap(16),
          const Divider(),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.listFiltersSortByControlLabel),
              const Gap(16),
              SegmentedButton<SortBy>(
                selectedIcon: const Icon(UniconsLine.check),
                segments: [
                  ButtonSegment(
                    value: SortBy.name,
                    label: Text(
                      AppLocalizations.of(context)!.sortByNameOptionsLabel,
                    ),
                    icon: const Icon(UniconsLine.tag),
                  ),
                  ButtonSegment(
                    value: SortBy.date,
                    label: Text(
                      AppLocalizations.of(context)!.sortByDateOptionsLabel,
                    ),
                    icon: const Icon(UniconsLine.clock),
                  ),
                  ButtonSegment(
                    value: SortBy.size,
                    label: Text(
                      AppLocalizations.of(context)!.sortBySizeOptionsLabel,
                    ),
                    icon: const Icon(UniconsLine.database),
                  ),
                ],
                selected: _sortBy,
                onSelectionChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.setInt('modelsSortBy', value.first.index);

                  setState(() {
                    _sortBy = value;
                  });
                },
              ),
              const Gap(16),
              Text(
                AppLocalizations.of(context)!.listFiltersSortOrderControlLabel,
              ),
              const Gap(16),
              SegmentedButton<SortOrder>(
                selectedIcon: const Icon(UniconsLine.check),
                segments: [
                  ButtonSegment(
                    value: SortOrder.ascending,
                    label: Text(
                      AppLocalizations.of(context)!
                          .sortOrderAscendingOptionsLabel,
                    ),
                    icon: const Icon(UniconsLine.arrow_up),
                  ),
                  ButtonSegment(
                    value: SortOrder.descending,
                    label: Text(
                      AppLocalizations.of(context)!
                          .sortOrderDescendingOptionsLabel,
                    ),
                    icon: const Icon(UniconsLine.arrow_down),
                  ),
                ],
                selected: _sortOrder,
                onSelectionChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();

                  if (value.contains(SortOrder.descending)) {
                    await prefs.setBool('modelsSortOrder', true);
                  } else {
                    await prefs.setBool('modelsSortOrder', false);
                  }

                  setState(() {
                    _sortOrder = value;
                  });
                },
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: ListView.builder(
              prototypeItem: ModelListTile(
                model: prototypeModel,
                pageController: widget.pageController,
              ),
              itemCount: context.watch<ModelProvider>().modelsCount,
              itemBuilder: (context, index) {
                return ModelListTile(
                  model: sortedModels[index],
                  pageController: widget.pageController,
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 900.ms, delay: 300.ms)
                    .move(
                      begin: const Offset(-16, 0),
                      curve: Curves.easeOutQuad,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ModelListTile extends StatefulWidget {
  final Model model;
  final PageController pageController;

  const ModelListTile({
    super.key,
    required this.model,
    required this.pageController,
  });

  @override
  State<ModelListTile> createState() => _ModelListTileState();
}

class _ModelListTileState extends State<ModelListTile> {
  void _setModel(Model model) async {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
        SnackBarType.error,
      );
    } else {
      if (!context.read<ChatProvider>().isSessionSelected) {
        final session = context.read<ChatProvider>().addSession('');
        context.read<ChatProvider>().setSession(session.uuid);
      }

      context.read<ChatProvider>().setModel(model.name);
      widget.pageController.jumpToPage(PageIndex.chat.index);
    }
  }

  void _deleteModel() async {
    if (context.read<ChatProvider>().modelName == widget.model.name) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
        SnackBarType.error,
      );
    } else {
      context.read<ModelProvider>().remove(widget.model.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.model.name),
      subtitle: Text(
        AppLocalizations.of(context)!.modifiedAtTextShared(
          DateTimeHelpers.formattedDateTime(widget.model.modifiedAt),
        ),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.modelsPageUseButton,
            icon: const Icon(UniconsLine.enter),
            onPressed: () => _setModel(widget.model),
          ),
          const Gap(8),
          IconButton(
            tooltip: AppLocalizations.of(context)!.modelsPageDeleteButton,
            icon: const Icon(
              UniconsLine.trash,
              color: Colors.red,
            ),
            onPressed: () {
              showConfirmationDialog(
                context: context,
                title:
                    AppLocalizations.of(context)!.modelsPageDeleteDialogTitle,
                content:
                    AppLocalizations.of(context)!.modelsPageDeleteDialogText(
                  widget.model.name,
                ),
                onConfirm: () => _deleteModel(),
              );
            },
          ),
        ],
      ),
      onTap: () {
        showModelDetailsDialog(widget.model, context);
      },
    );
  }
}
