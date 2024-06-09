import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatToolbarWidget extends StatefulWidget {
  const ChatToolbarWidget({super.key});

  @override
  State<ChatToolbarWidget> createState() => _ChatToolbarWidgetState();
}

class _ChatToolbarWidgetState extends State<ChatToolbarWidget> {
  void _newSession() {
    if (context.read<ChatProvider>().isSessionSelected) {
      if (context.read<ChatProvider>().session!.messages.isEmpty) {
        SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context)!.noNeedToCreateSessionSnackBarText,
          SnackBarType.info,
        );
      } else if (context.read<ChatProvider>().isGenerating) {
        SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context)!.modelIsGeneratingSnackBarText,
          SnackBarType.error,
        );
      } else {
        context.read<ChatProvider>().newSession();
      }
    } else {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context)!.noNeedToCreateSessionSnackBarText,
        SnackBarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ChatModelSelectionWidget(),
          const Gap(16),
          const ChatOptionBarWidget(),
          const Gap(16),
          ElevatedButton.icon(
            label: Text(
              AppLocalizations.of(context)!.chatToolbarNewSessionButton,
              style: const TextStyle(fontSize: 18.0),
            ),
            icon: const Icon(UniconsLine.plus),
            onPressed: !context.watch<ChatProvider>().isGenerating
                ? () => _newSession()
                : null,
          )
        ],
      ),
    );
  }
}

class ChatOptionBarWidget extends StatelessWidget {
  const ChatOptionBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AdaptiveTheme.of(context).theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.chatToolbarWebSearchOption),
              Checkbox(
                value: context.watch<ChatProvider>().isWebSearchEnabled,
                onChanged: !context.watch<ChatProvider>().isGenerating
                    ? (value) {
                        context
                            .read<ChatProvider>()
                            .enableWebSearch(value ?? false);
                      }
                    : null,
              ),
              const Gap(8),
              Text(AppLocalizations.of(context)!.chatToolbarDocsSearchOption),
              Checkbox(
                value: context.watch<ChatProvider>().isDocsSearchEnabled,
                onChanged: !context.watch<ChatProvider>().isGenerating
                    ? (value) {
                        context
                            .read<ChatProvider>()
                            .enableDocsSearch(value ?? false);
                      }
                    : null,
              ),
              const Gap(8),
              Text(AppLocalizations.of(context)!.chatToolbarAutoscrollOption),
              Checkbox(
                value: context.watch<ChatProvider>().isAutoscrollEnabled,
                onChanged: (value) {
                  context.read<ChatProvider>().enableAutoscroll(value ?? false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatModelSelectionWidget extends StatelessWidget {
  const ChatModelSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> modelsMenuEntries = [];

    for (final model in context.read<ModelProvider>().models) {
      final shortName = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;

      modelsMenuEntries.add(
        DropdownMenuEntry(
          value: model.name,
          label: shortName,
        ),
      );
    }

    return DropdownMenu(
      enabled: context.watch<ModelProvider>().modelsCount > 0 &&
          !context.watch<ChatProvider>().isGenerating,
      menuHeight: 128,
      menuStyle: MenuStyle(
        elevation: WidgetStateProperty.all(
          8.0,
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      enableSearch: true,
      hintText: AppLocalizations.of(context)!.chatToolbarModelSelectorHint,
      initialSelection: context.watch<ChatProvider>().modelName,
      dropdownMenuEntries: modelsMenuEntries,
      onSelected: (value) => context.read<ChatProvider>().setModel(value ?? ''),
    );
  }
}
