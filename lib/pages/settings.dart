import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:open_local_ui/layout/page_base.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdaptiveTheme.of(context).theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: _buildThemeSettings(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    String themeModeString;

    switch (AdaptiveTheme.of(context).mode) {
      case AdaptiveThemeMode.light:
        themeModeString = 'Light';
        break;
      case AdaptiveThemeMode.dark:
        themeModeString = 'Dark';
        break;
      case AdaptiveThemeMode.system:
        themeModeString = 'System';
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Theme',
          style: TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 8.0),
        DropdownMenu(
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          initialSelection: themeModeString,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'Light', label: 'Light'),
            DropdownMenuEntry(value: 'Dark', label: 'Dark'),
            DropdownMenuEntry(value: 'System', label: 'System'),
          ],
          onSelected: (value) {
            switch (value) {
              case 'Light':
                AdaptiveTheme.of(context).setLight();
                break;
              case 'Dark':
                AdaptiveTheme.of(context).setDark();
                break;
              case 'System':
                AdaptiveTheme.of(context).setSystem();
                break;
            }
          },
        ),
      ],
    );
  }
}
