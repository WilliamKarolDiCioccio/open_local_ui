import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/dialogs/confirmation.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/dashboard.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:provider/provider.dart';
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

class SessionsPage extends StatefulWidget {
  final PageController pageController;

  const SessionsPage({super.key, required this.pageController});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  Set<SortBy> _sortBy = {SortBy.name};
  Set<SortOrder> _sortOrder = {SortOrder.ascending};

  final prototypeChatSession = ChatSessionWrapper('', '', '');

  void _deleteSession(String uuid) {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().removeSession(uuid);
    }
  }

  void _setSession(ChatSessionWrapper session) {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().setSession(session.uuid);
      widget.pageController.jumpToPage(PageIndex.chat.index);
    }
  }

  Widget _buildModelListTile(ChatSessionWrapper session, BuildContext context) {
    return ListTile(
      title: Text(session.title),
      subtitle: Text(session.createdAt.toString()),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageEnterButton,
            icon: const Icon(UniconsLine.enter),
            onPressed: () => _setSession(session),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageDeleteButton,
            icon: const Icon(
              UniconsLine.trash,
              color: Colors.red,
            ),
            onPressed: () {
              showConfirmationDialog(
                context: context,
                title:
                    AppLocalizations.of(context)!.sessionsPageDeleteDialogTitle,
                content: AppLocalizations.of(context)!
                    .sessionsPageDeleteDialogText(session.title),
                onConfirm: () => _deleteSession(session.uuid),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var sortedSessions = context.watch<ChatProvider>().sessions;

    sortedSessions.sort(
      (a, b) {
        if (_sortBy.contains(SortBy.name)) {
          return a.title.compareTo(b.title);
        } else if (_sortBy.contains(SortBy.date)) {
          return DateTime.parse(
            a.createdAt,
          ).compareTo(
            DateTime.parse(
              b.createdAt,
            ),
          );
        } else if (_sortBy.contains(SortBy.size)) {
          return a.title.length.compareTo(b.title.length);
        }
        return 0;
      },
    );
    
    if (_sortOrder.contains(SortOrder.descending)) {
      sortedSessions = sortedSessions.reversed.toList();
    }

    return PageBaseLayout(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.sessionsPageTitle,
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
                  AppLocalizations.of(context)!.sessionsPageCreateFolderButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
                icon: const Icon(UniconsLine.folder_plus),
                onPressed: () => {},
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
                onSelectionChanged: (value) => {
                  setState(() {
                    _sortBy = value;
                  })
                },
              ),
              const Gap(16),
              Text(AppLocalizations.of(context)!
                  .listFiltersSortOrderControlLabel),
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
                onSelectionChanged: (value) => {
                  setState(() {
                    _sortOrder = value;
                  })
                },
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: ListView.builder(
              prototypeItem: _buildModelListTile(
                prototypeChatSession,
                context,
              ),
              itemCount: context.watch<ChatProvider>().sessionCount,
              itemBuilder: (context, index) {
                return _buildModelListTile(
                  sortedSessions[index],
                  context,
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
