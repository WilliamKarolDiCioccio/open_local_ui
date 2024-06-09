import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/dialogs/confirmation.dart';
import 'package:open_local_ui/dialogs/create_folder.dart';
import 'package:open_local_ui/helpers/datetime.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/dashboard.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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

class SessionsPage extends StatefulWidget {
  final PageController pageController;

  const SessionsPage({super.key, required this.pageController});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late Set<SortBy> _sortBy;
  late Set<SortOrder> _sortOrder;

  final prototypeChatSession = ChatSessionWrapper(
    '',
    DateTime(0),
    '',
    [],
  );

  @override
  void initState() {
    super.initState();

    _sortBy = {SortBy.name};
    _sortOrder = {SortOrder.ascending};

    SharedPreferences.getInstance().then((prefs) {
      final sortBy = prefs.getInt('sessionsSortBy') ?? 0;
      final sortOrder = prefs.getBool('sessionsSortOrder') ?? false;

      setState(() {
        _sortBy = {SortBy.values[sortBy]};
        _sortOrder = {sortOrder ? SortOrder.descending : SortOrder.ascending};
      });
    });
  }

  void _setSession(ChatSessionWrapper session) {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().setSession(session.uuid);
      widget.pageController.jumpToPage(PageIndex.chat.index);
    }
  }

  void _shareSession(ChatSessionWrapper session) async {
    if (session.status == ChatSessionStatus.generating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
        SnackBarType.error,
      );
    } else {
      late ShareResult shareResult;

      if (Platform.isLinux) {
        shareResult = await Share.share(session.toJson().toString());
      } else {
        final cacheDir = await getApplicationCacheDirectory();

        final file = File('${cacheDir.path}/${session.uuid}.json');
        await file.writeAsString(session.toJson().toString());

        final shareFile = XFile(
          file.path,
          mimeType: 'application/json',
          name: session.title,
          lastModified: session.messages.last.createdAt,
        );

        shareResult = await Share.shareXFiles(
          [shareFile],
          text: session.title,
        );
      }

      if (shareResult.status == ShareResultStatus.success) {
        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context)!.sessionSharedSnackBarText,
          SnackBarType.success,
        );
      } else {
        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context)!.failedToShareSessionSnackBarText,
          SnackBarType.error,
        );
      }
    }
  }

  void _deleteSession(String uuid) async {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().removeSession(uuid);
    }
  }

  Widget _buildModelListTile(ChatSessionWrapper session, BuildContext context) {
    return ListTile(
      title: Text(session.title),
      subtitle: Text(
        AppLocalizations.of(context)!.createdAtTextShared(
          DateTimeHelpers.formattedDateTime(session.createdAt),
        ),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageEnterButton,
            icon: const Icon(UniconsLine.enter),
            onPressed: () => _setSession(session),
          ),
          const Gap(8),
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageShareButton,
            icon: const Icon(UniconsLine.share),
            onPressed: () => _shareSession(session),
          ),
          const Gap(8),
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
          return a.createdAt.compareTo(b.createdAt);
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
                onPressed: () => showCreateFolderDialog(context),
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

                  await prefs.setInt('sessionsSortBy', value.first.index);

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
                    await prefs.setBool('sessionsSortOrder', true);
                  } else {
                    await prefs.setBool('sessionsSortOrder', false);
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
