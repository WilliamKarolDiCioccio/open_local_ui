import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:open_local_ui/controller/chat_controller.dart';

class ChatToolbarWidget extends StatefulWidget {
  const ChatToolbarWidget({super.key});

  @override
  State<ChatToolbarWidget> createState() => _ChatToolbarWidgetState();
}

class _ChatToolbarWidgetState extends State<ChatToolbarWidget> {
  bool webSearchEnabled = true;
  bool docsSearchEnabled = true;
  bool autoScrollEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: [
            DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              enableFilter: true,
              enableSearch: true,
              label: const Text('Model'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'llama2', label: 'llama2'),
              ],
              onSelected: (value) =>
                  ChatSessionController.setModelName(value ?? ''),
            ),
            const SizedBox(width: 8.0),
            Expanded(
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
                      webSearchEnabled,
                      (value) => setState(() {
                        webSearchEnabled = value ?? false;
                        ChatSessionController.enableWebSearch(webSearchEnabled);
                      }),
                    ),
                    _buildCheckbox(
                      'Docs search:',
                      docsSearchEnabled,
                      (value) => setState(() {
                        docsSearchEnabled = value ?? false;
                        ChatSessionController.enableDocsSearch(docsSearchEnabled);
                      }),
                    ),
                    _buildCheckbox(
                      'Auto scroll:',
                      autoScrollEnabled,
                      (value) => setState(() {
                        autoScrollEnabled = value ?? false;
                        ChatSessionController.enableAutoScroll(autoScrollEnabled);
                      }),
                    )
                  ],
                ),
              ),
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
