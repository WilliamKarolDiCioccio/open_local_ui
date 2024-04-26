import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';

class ChatToolbarWidget extends StatefulWidget {
  const ChatToolbarWidget({super.key});

  @override
  State<ChatToolbarWidget> createState() => _ChatToolbarWidgetState();
}

class _ChatToolbarWidgetState extends State<ChatToolbarWidget> {
  bool _webSearchEnabled = false;
  bool _docsSearchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModelSelector(),
        const SizedBox(width: 16.0),
        _buildOptionsBar(),
        const SizedBox(width: 16.0),
        TextIconButtonComponent(
          text: AppLocalizations.of(context)!.chatToolbarNewChatButton,
          icon: UniconsLine.plus,
          onPressed: () => context.read<ChatProvider>().clearHistory(),
        )
      ],
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
      enableFilter: true,
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
          _buildCheckbox(
            AppLocalizations.of(context)!.chatToolbarWebSearchOption,
            _webSearchEnabled,
            (value) => setState(() {
              context.read<ChatProvider>().enableWebSearch(value ?? false);
              _webSearchEnabled = value ?? false;
            }),
          ),
          _buildCheckbox(
            AppLocalizations.of(context)!.chatToolbarDocsSearchOption,
            _docsSearchEnabled,
            (value) => setState(() {
              context.read<ChatProvider>().enableDocsSearch(value ?? false);
              _docsSearchEnabled = value ?? false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String text, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Text(text),
        Checkbox(value: value, onChanged: onChanged),
      ],
    );
  }
}
