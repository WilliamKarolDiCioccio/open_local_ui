import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/dialogs/confirmation.dart';
import 'package:open_local_ui/dialogs/create_model.dart';
import 'package:open_local_ui/dialogs/model_details.dart';
import 'package:open_local_ui/dialogs/pull_model.dart';
import 'package:open_local_ui/dialogs/push_model.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/models/model.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  @override
  void initState() {
    super.initState();
    
    context.read<ModelProvider>().updateList();
  }

  void _deleteModel(String name) {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelper.showSnackBar(
        AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
        SnackBarType.error,
      );
    } else {
      context.read<ModelProvider>().remove(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProvider>(
      builder: (context, value, child) => PageBaseLayout(
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
            const SizedBox(height: 16.0),
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
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: context.read<ModelProvider>().modelsCount,
                itemBuilder: (context, index) {
                  return _buildModelListTile(
                    context.read<ModelProvider>().models[index],
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

  Widget _buildModelListTile(Model model, BuildContext context) {
    return ListTile(
      title: Text(model.name),
      subtitle: Text(
        AppLocalizations.of(context)!.modelDetailsDialogModifiedAtText(
          model.modifiedAt.toString(),
        ),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.modelsPageDeleteButton,
            icon: const Icon(UniconsLine.trash),
            onPressed: () {
              showConfirmationDialog(
                context: context,
                title: AppLocalizations.of(context)!.modelsPageDeleteDialogTitle,
                content: AppLocalizations.of(context)!.modelsPageDeleteDialogText(model.name),
                onConfirm: () => _deleteModel(model.name),
              );
            },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.modelsPageUseButton,
            icon: const Icon(UniconsLine.enter),
            onPressed: () {
              context.read<ChatProvider>().setModel(model.name);
              final session = context.read<ChatProvider>().addSession('');
              context.read<ChatProvider>().setSession(session.uuid);
            },
          ),
        ],
      ),
      onTap: () {
        showModelDetailsDialog(model, context);
      },
    );
  }
}
