import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';

class ChatToolbarWidget extends StatefulWidget {
  const ChatToolbarWidget({super.key});

  @override
  State<ChatToolbarWidget> createState() => _ChatToolbarWidgetState();
}

class _ChatToolbarWidgetState extends State<ChatToolbarWidget> {
  void _newSession() {
    if (context.read<ChatProvider>().isSessionSelected) {
      if (context.read<ChatProvider>().session!.messages.isEmpty) {
        SnackBarHelper.showSnackBar(
          AppLocalizations.of(context)!.noNeedToCreateSessionSnackbarText,
          SnackBarType.info,
        );
      } else if (context.read<ChatProvider>().isGenerating) {
        SnackBarHelper.showSnackBar(
          AppLocalizations.of(context)!.modelIsGeneratingSnackbarText,
          SnackBarType.error,
        );
      } else {
        context.read<ChatProvider>().newSession();
      }
    } else {
      SnackBarHelper.showSnackBar(
        AppLocalizations.of(context)!.noNeedToCreateSessionSnackbarText,
        SnackBarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, value, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModelSelector(),
          const SizedBox(width: 16.0),
          _buildOptionsBar(),
          const SizedBox(width: 16.0),
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context)!.chatToolbarNewSessionButton,
              style: const TextStyle(fontSize: 18.0),
            ),
            icon: const Icon(UniconsLine.plus),
            onPressed: () => _newSession(),
          )
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    final List<DropdownMenuEntry> modelsMenuEntries = [];

    for (final model in context.read<ModelProvider>().models) {
      final shortName = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;

      modelsMenuEntries
          .add(DropdownMenuEntry(value: model.name, label: shortName));
    }

    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      enableSearch: true,
      hintText: AppLocalizations.of(context)!.chatToolbarModelSelectorHint,
      initialSelection: context.watch<ChatProvider>().modelName,
      dropdownMenuEntries: modelsMenuEntries,
      onSelected: (value) => context.read<ChatProvider>().setModel(value ?? ''),
    );
  }

  Widget _buildOptionsBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AdaptiveTheme.of(context).theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.chatToolbarWebSearchOption),
              Checkbox(
                value: context.watch<ChatProvider>().isWebSearchEnabled,
                onChanged: (value) {
                  context.read<ChatProvider>().enableWebSearch(value ?? false);
                },
              ),
            ],
          ),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.chatToolbarDocsSearchOption),
              Checkbox(
                value: context.watch<ChatProvider>().isDocsSearchEnabled,
                onChanged: (value) {
                  context.read<ChatProvider>().enableDocsSearch(value ?? false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
