import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/dialogs/confirmation.dart';
import 'package:open_local_ui/layout/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/providers/chat.dart';

class SessionsPage extends StatefulWidget {
  final PageController pageController;

  const SessionsPage({super.key, required this.pageController});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, value, child) => PageBaseLayout(
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
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: context.watch<ChatProvider>().sessionCount,
                itemBuilder: (context, index) {
                  final session = context.watch<ChatProvider>().sessions[index];
                  return _buildModelListTile(
                    session,
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
      ),
    );
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
            onPressed: () {
              context.read<ChatProvider>().setSession(session.uuid);
              widget.pageController.jumpToPage(PageIndex.chat.index);
            },
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
}
