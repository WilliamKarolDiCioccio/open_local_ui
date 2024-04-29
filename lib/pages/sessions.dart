import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/chat_session.dart';
import 'package:open_local_ui/providers/chat.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  void _deleteSession(String uuid) {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        context,
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().removeSession(uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
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
                itemCount: context.read<ChatProvider>().sessionCount,
                itemBuilder: (context, index) {
                  return _buildModelListTile(
                      context.read<ChatProvider>().sessions[index], context);
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
      subtitle: Text(
        session.createdAt.toString(),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageDeleteButton,
            icon: const Icon(UniconsLine.trash),
            onPressed: () => _deleteSession(session.uuid),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.sessionsPageOpenButton,
            icon: const Icon(UniconsLine.enter),
            onPressed: () {
              context.read<ChatProvider>().setSession(session.uuid);
            },
          ),
        ],
      ),
    );
  }
}
