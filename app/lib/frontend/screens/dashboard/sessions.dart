// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_local_ui/backend/private/models/chat_session.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/core/format.dart';
import 'package:open_local_ui/frontend/dialogs/confirmation.dart';
import 'package:open_local_ui/frontend/dialogs/text_field.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/utils/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:unicons/unicons.dart';
import 'package:units_converter/units_converter.dart';
import 'package:url_launcher/url_launcher.dart';

enum SessionsSortBy {
  name,
  date,
  size,
}

enum SessionsSortOrder {
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
  late Set<SessionsSortBy> _sortBy;
  late Set<SessionsSortOrder> _sortOrder;

  final prototypeChatSession = ChatSessionWrapperV1(
    DateTime(0),
    '',
    [],
  );

  @override
  void initState() {
    super.initState();

    _sortBy = {SessionsSortBy.name};
    _sortOrder = {SessionsSortOrder.ascending};

    SharedPreferences.getInstance().then(
      (prefs) {
        final sortBy = prefs.getInt('sessions_sort_by') ?? 0;
        final sortOrder = prefs.getBool('sessions_sort_order') ?? false;

        if (mounted) {
          setState(
            () {
              _sortBy = {SessionsSortBy.values[sortBy]};
              _sortOrder = {
                sortOrder
                    ? SessionsSortOrder.descending
                    : SessionsSortOrder.ascending,
              };
            },
          );
        }
      },
    );
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
        if (_sortBy.contains(SessionsSortBy.name)) {
          return a.title.compareTo(b.title);
        } else if (_sortBy.contains(SessionsSortBy.date)) {
          return a.createdAt.compareTo(b.createdAt);
        } else if (_sortBy.contains(SessionsSortBy.size)) {
          return a.title.length.compareTo(b.title.length);
        }
        return 0;
      },
    );

    if (_sortOrder.contains(SessionsSortOrder.descending)) {
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
            TextButton.icon(
              label: Text(
                AppLocalizations.of(context).sessionsPageClearSessionsButton,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.red,
                ),
              ),
              icon: const Icon(
                UniconsLine.trash,
                color: Colors.red,
              ),
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
            SegmentedButton<SessionsSortBy>(
              selectedIcon: const Icon(UniconsLine.check),
              segments: [
                ButtonSegment(
                  value: SessionsSortBy.name,
                  label: Text(
                    AppLocalizations.of(context).sortByNameOption,
                  ),
                  icon: const Icon(UniconsLine.tag),
                ),
                ButtonSegment(
                  value: SessionsSortBy.date,
                  label: Text(
                    AppLocalizations.of(context).sortByDateOption,
                  ),
                  icon: const Icon(UniconsLine.clock),
                ),
                ButtonSegment(
                  value: SessionsSortBy.size,
                  label: Text(
                    AppLocalizations.of(context).sortBySizeOption,
                  ),
                  icon: const Icon(UniconsLine.database),
                ),
              ],
              selected: _sortBy,
              onSelectionChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.setInt('sessions_sort_by', value.first.index);

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
            SegmentedButton<SessionsSortOrder>(
              selectedIcon: const Icon(UniconsLine.check),
              segments: [
                ButtonSegment(
                  value: SessionsSortOrder.ascending,
                  label: Text(
                    AppLocalizations.of(context).sortOrderAscendingOption,
                  ),
                  icon: const Icon(UniconsLine.sort_amount_up),
                ),
                ButtonSegment(
                  value: SessionsSortOrder.descending,
                  label: Text(
                    AppLocalizations.of(context).sortOrderDescendingOption,
                  ),
                  icon: const Icon(UniconsLine.sort_amount_down),
                ),
              ],
              selected: _sortOrder,
              onSelectionChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();

                if (value.contains(SessionsSortOrder.descending)) {
                  await prefs.setBool('sessions_sort_order', true);
                } else {
                  await prefs.setBool('sessions_sort_order', false);
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
          child: DynMouseScroll(
            controller: ScrollController(),
            builder: (context, controller, physics) => ListView.builder(
              shrinkWrap: true,
              physics: physics,
              controller: controller,
              prototypeItem: !_sortBy.contains(SessionsSortBy.date)
                  ? SessionListTile(
                      session: prototypeChatSession,
                      pageController: widget.pageController,
                    )
                  : null,
              itemCount: context.watch<ChatProvider>().sessionCount,
              itemBuilder: (context, index) {
                final session = sortedSessions[index];
                final previousSession =
                    index > 0 ? sortedSessions[index - 1] : null;

                final bool showDateHeader =
                    _sortBy.contains(SessionsSortBy.date) &&
                        previousSession != null &&
                        session.createdAt.day != previousSession.createdAt.day;

                final sessionTile = SessionListTile(
                  session: session,
                  pageController: widget.pageController,
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 900.ms, delay: 300.ms)
                    .move(
                      begin: const Offset(-16, 0),
                      curve: Curves.easeOutQuad,
                    );

                if (showDateHeader) {
                  final isOlderThanSixDays =
                      DateTime.now().difference(session.createdAt).inDays > 6;

                  final sessionDateText = isOlderThanSixDays
                      ? FormatHelpers.standardDate(session.createdAt)
                      : DateFormat('EEEE').format(session.createdAt);

                  final dateHeaderText = 'Before $sessionDateText';

                  final dateHeader = Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateHeaderText,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                      ],
                    ).animate(delay: (index * 100).ms).fadeIn(
                          duration: 900.ms,
                          delay: 300.ms,
                        ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dateHeader,
                      sessionTile,
                    ],
                  );
                } else {
                  return sessionTile;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SessionListTile extends StatefulWidget {
  final ChatSessionWrapperV1 session;
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
  Future<void> _setSession() async {
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

  Future<void> _shareSession() async {
    if (widget.session.status == ChatSessionStatus.generating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    } else {
      final targetDir = (await getDownloadsDirectory())?.path ?? '.';

      final file = File(
        '$targetDir/OpenLocalUI_Chat_${widget.session.uuid}.json',
      );

      await file.writeAsString(widget.session.toJson().toString());

      if (await launchUrl(file.uri)) {
        SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).snackBarSuccessTitle,
          AppLocalizations.of(context).sessionSharedSnackBar,
          SnackbarContentType.success,
        );
      } else {
        SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).snackBarErrorTitle,
          AppLocalizations.of(context).failedToShareSessionSnackBar,
          SnackbarContentType.failure,
        );
      }
    }
  }

  Future<void> _deleteSession() async {
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

  Future<void> _editSessionTitle() async {
    await showTextFieldDialog(
      context: context,
      title: AppLocalizations.of(context).sessionsPageEditDialogTitle,
      labelText: AppLocalizations.of(context).sessionsPageEditDialogLabel,
      initialValue: widget.session.title,
      onConfirm: (newName) {
        if (widget.session.status == ChatSessionStatus.generating) {
          SnackBarHelpers.showSnackBar(
            AppLocalizations.of(context).snackBarErrorTitle,
            AppLocalizations.of(context).modelIsGeneratingSnackBar,
            SnackbarContentType.failure,
          );
        } else {
          if (newName.isNotEmpty) {
            context.read<ChatProvider>().setSessionTitle(
                  widget.session.uuid,
                  newName,
                );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext content) {
    return ListTile(
      title: Text(widget.session.title),
      subtitle: Text(
        AppLocalizations.of(context).createdAtTextShared(
          FormatHelpers.standardDate(widget.session.createdAt),
        ),
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip:
                    AppLocalizations.of(context).sessionsPageEditTitleButton,
                icon: const Icon(UniconsLine.edit),
                onPressed: () => _editSessionTitle(),
              ),
              const Gap(8),
              IconButton(
                tooltip: AppLocalizations.of(context).sessionsPageShareButton,
                icon: const Icon(UniconsLine.share),
                onPressed: () => _shareSession(),
              ),
              const Gap(8),
              IconButton(
                tooltip: AppLocalizations.of(context).sessionsPageDeleteButton,
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
        ],
      ),
      onTap: () => _setSession(),
    );
  }
}
