import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:open_local_ui/layout/page_base.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _sliderValue = 0;

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
          const SizedBox(width: 16.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdaptiveTheme.of(context).theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: _buildAccessibilitySettings(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: TextStyle(fontSize: 24.0),
        ),
        Divider(),
        ThemeSwtch(),
      ],
    );
  }

  Widget _buildAccessibilitySettings(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Accessibility',
          style: TextStyle(fontSize: 24.0),
        ),
        const Divider(),
        const Text('Language'),
        DropdownMenu(
          width: 150.0,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          enableFilter: true,
          enableSearch: true,
          hintText: 'Select language',
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'Default', label: 'Default'),
          ],
          onSelected: (value) {},
        ),
        const Text('Color blindness'),
        Slider(
          min: 0,
          max: 7,
          divisions: 7,
          value: _sliderValue,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
        ),
      ],
    );
  }
}

class ThemeSwtch extends StatelessWidget {
  const ThemeSwtch({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Light'),
        const SizedBox(width: 8.0),
        Switch(
          value: AdaptiveTheme.of(context).mode.isDark,
          onChanged: (value) {
            if (value) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),
        const SizedBox(width: 8.0),
        const Text('Dark'),
      ],
    );
  }
}
