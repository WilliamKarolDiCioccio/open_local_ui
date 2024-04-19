import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:open_local_ui/components/text_icon_button.dart';
import 'package:open_local_ui/controllers/chat_controller.dart';
import 'package:open_local_ui/controllers/model_controller.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatToolbarWidget extends StatefulWidget {
  const ChatToolbarWidget({super.key});

  @override
  State<ChatToolbarWidget> createState() => _ChatToolbarWidgetState();
}

class _ChatToolbarWidgetState extends State<ChatToolbarWidget> {
  bool _webSearchEnabled = false;
  bool _docsSearchEnabled = false;
  bool _autoScrollEnabled = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Row(
        children: [
          _buildModelSelector(),
          const SizedBox(width: 16.0),
          _buildOptionsBar(),
          const SizedBox(width: 16.0),
          TextIconButtonComponent(
            text: 'New chat',
            icon: UniconsLine.plus,
            onPressed: () => Provider.of<ChatController>(context, listen: false)
                .clearHistory(),
          )
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    final List<DropdownMenuEntry> modelsMenuEntries = [];

    for (final model in context.read<ModelController>().models) {
      final name = model.name.length > 20
          ? '${model.name.substring(0, 20)}...'
          : model.name;
      modelsMenuEntries.add(DropdownMenuEntry(value: name, label: name));
    }

    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      enableFilter: true,
      enableSearch: true,
      hintText: 'Select model',
      initialSelection: context.read<ChatController>().modelName,
      dropdownMenuEntries: modelsMenuEntries,
      onSelected: (value) =>
          context.read<ChatController>().setModelName(value ?? ''),
    );
  }

  Widget _buildOptionsBar() {
    return Expanded(
      child: Container(
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
              'Web search:',
              _webSearchEnabled,
              (value) => setState(() {
                Provider.of<ChatController>(context, listen: false)
                    .enableWebSearch(value ?? false);
                _webSearchEnabled = value ?? false;
              }),
            ),
            _buildCheckbox(
              'Docs search:',
              _docsSearchEnabled,
              (value) => setState(() {
                Provider.of<ChatController>(context, listen: false)
                    .enableDocsSearch(value ?? false);
                _docsSearchEnabled = value ?? false;
              }),
            ),
            _buildCheckbox(
              'Auto scroll:',
              _autoScrollEnabled,
              (value) => setState(() {
                Provider.of<ChatController>(context, listen: false)
                    .enableAutoScroll(value ?? false);
                _autoScrollEnabled = value ?? false;
              }),
            )
          ],
        ),
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
