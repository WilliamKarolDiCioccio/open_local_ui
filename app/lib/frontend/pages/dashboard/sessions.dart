import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/models/chat_session.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/core/format.dart';
import 'package:open_local_ui/frontend/dialogs/confirmation.dart';
import 'package:open_local_ui/core/snackbar.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<int> _totalOnDiskSize() async {
    final dataDir = await getApplicationSupportDirectory();
    final sessionsFile = File('${dataDir.path}/sessions/sessions.hive');

    if (await sessionsFile.exists()) {
      return await sessionsFile.length();
    }

    return 0;
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).sessionsPageTitle,
          style: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TextButton.icon(
            //   label: Text(
            //     AppLocalizations.of(context).sessionsPageCreateFolderButton,
            //     style: const TextStyle(fontSize: 18.0),
            //   ),
            //   icon: const Icon(UniconsLine.folder_plus),
            //   onPressed: () => {},
            // ),
            TextButton.icon(
              label: Text(
                AppLocalizations.of(context).sessionsPageClearSessionsButton,
                style: const TextStyle(fontSize: 18.0),
              ),
              icon: const Icon(UniconsLine.trash),
              onPressed: () {
                showConfirmationDialog(
                  context: context,
                  title:
                      AppLocalizations.of(context).sessionsPageClearDialogTitle,
                  content:
                      AppLocalizations.of(context).sessionsPageClearDialogText,
                  onConfirm: () => context.read<ChatProvider>().clearSessions(),
                );
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
            Text(AppLocalizations.of(context).listFiltersSortByLabel),
            const Gap(16),
            SegmentedButton<SortBy>(
              selectedIcon: const Icon(UniconsLine.check),
              segments: [
                ButtonSegment(
                  value: SortBy.name,
                  label: Text(
                    AppLocalizations.of(context).sortByNameOption,
                  ),
                  icon: const Icon(UniconsLine.tag),
                ),
                ButtonSegment(
                  value: SortBy.date,
                  label: Text(
                    AppLocalizations.of(context).sortByDateOption,
                  ),
                  icon: const Icon(UniconsLine.clock),
                ),
                ButtonSegment(
                  value: SortBy.size,
                  label: Text(
                    AppLocalizations.of(context).sortBySizeOption,
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
              AppLocalizations.of(context).listFiltersSortOrderLabel,
            ),
            const Gap(16),
            SegmentedButton<SortOrder>(
              selectedIcon: const Icon(UniconsLine.check),
              segments: [
                ButtonSegment(
                  value: SortOrder.ascending,
                  label: Text(
                    AppLocalizations.of(context).sortOrderAscendingOption,
                  ),
                  icon: const Icon(UniconsLine.arrow_up),
                ),
                ButtonSegment(
                  value: SortOrder.descending,
                  label: Text(
                    AppLocalizations.of(context).sortOrderDescendingOption,
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
            const Spacer(),
            FutureBuilder(
              future: _totalOnDiskSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    AppLocalizations.of(context).totalOnDiskSizeLabel(
                      '${snapshot.data!.convertFromTo(
                            DIGITAL_DATA.byte,
                            DIGITAL_DATA.megabyte,
                          )!.toStringAsFixed(2)} MB',
                    ),
                  );
                } else {
                  return const Text('');
                }
              },
            ),
          ],
        ),
        const Gap(16),
        Expanded(
          child: ListView.builder(
            prototypeItem: SessionListTile(
              session: prototypeChatSession,
              pageController: widget.pageController,
            ),
            itemCount: context.watch<ChatProvider>().sessionCount,
            itemBuilder: (context, index) {
              return SessionListTile(
                session: sortedSessions[index],
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
    );
  }
}

class SessionListTile extends StatefulWidget {
  final ChatSessionWrapper session;
  final PageController pageController;

  const SessionListTile({
    super.key,
    required this.session,
    required this.pageController,
  });

  @override
  State<SessionListTile> createState() => _SessionListTileState();
}

class _SessionListTileState extends State<SessionListTile> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _showEditWidget = false;

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  void _setSession() async {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    } else {
      context.read<ChatProvider>().setSession(widget.session.uuid);
      widget.pageController.jumpToPage(PageIndex.chat.index);
    }
  }

  void _beginEditingTitle() {
    setState(() {
      _showEditWidget = true;
    });

    _textEditingController.text = widget.session.title;
  }

  void _sendEditedTitle() {
    if (widget.session.status == ChatSessionStatus.generating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    } else {
      if (_textEditingController.text.isEmpty) return;

      context.read<ChatProvider>().setSessionTitle(
            widget.session.uuid,
            _textEditingController.text,
          );

      _cancelEditingTitle();
    }
  }

  void _cancelEditingTitle() {
    setState(() {
      _showEditWidget = false;
    });

    _textEditingController.clear();
  }

  void _shareSession() async {
    if (widget.session.status == ChatSessionStatus.generating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    } else {
      final targetDir = (await getDownloadsDirectory())?.path ?? '.';

      final file =
          File('$targetDir/OpenLocalUI_Chat_${widget.session.uuid}.json');
      await file.writeAsString(widget.session.toJson().toString());
      if (await launchUrl(file.uri)) {
        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context).snackBarSuccessTitle,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context).sessionSharedSnackBar,
          SnackbarContentType.success,
        );
      } else {
        SnackBarHelpers.showSnackBar(
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context).snackBarErrorTitle,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context).failedToShareSessionSnackBar,
          SnackbarContentType.failure,
        );
      }
    }
  }

  void _deleteSession() async {
    if (widget.session.status == ChatSessionStatus.generating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    } else {
      context.read<ChatProvider>().removeSession(widget.session.uuid);
    }
  }

  @override
  Widget build(BuildContext content) {
    return ListTile(
      leading: _showEditWidget
          ? Container(
              constraints: const BoxConstraints.tightForFinite(width: 256),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).chatEditFieldHint,
                  counterText: '',
                ),
                controller: _textEditingController,
              ),
            )
          : null,
      title: _showEditWidget ? null : Text(widget.session.title),
      subtitle: _showEditWidget
          ? null
          : Text(
              AppLocalizations.of(context).createdAtTextShared(
                FortmatHelpers.standardDate(widget.session.createdAt),
              ),
            ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_showEditWidget)
            Row(
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).sessionsPageEnterButton,
                  icon: const Icon(UniconsLine.enter),
                  onPressed: () => _setSession(),
                ),
                const Gap(8),
                IconButton(
                  tooltip:
                      AppLocalizations.of(context).sessionsPageEditTitleButton,
                  icon: const Icon(UniconsLine.edit),
                  onPressed: () => _beginEditingTitle(),
                ),
                const Gap(8),
                IconButton(
                  tooltip: AppLocalizations.of(context).sessionsPageShareButton,
                  icon: const Icon(UniconsLine.share),
                  onPressed: () => _shareSession(),
                ),
                const Gap(8),
                IconButton(
                  tooltip:
                      AppLocalizations.of(context).sessionsPageDeleteButton,
                  icon: const Icon(
                    UniconsLine.trash,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: AppLocalizations.of(context)
                          .sessionsPageDeleteDialogTitle,
                      content: AppLocalizations.of(context)
                          .sessionsPageDeleteDialogText(widget.session.title),
                      onConfirm: () => _deleteSession(),
                    );
                  },
                ),
              ],
            ),
          if (_showEditWidget)
            Row(
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).cancelButtonShared,
                  icon: const Icon(UniconsLine.times),
                  onPressed: () => _cancelEditingTitle(),
                ),
                const Gap(8),
                IconButton(
                  tooltip: AppLocalizations.of(context).saveButtonShared,
                  icon: const Icon(UniconsLine.check),
                  onPressed: () => _sendEditedTitle(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
