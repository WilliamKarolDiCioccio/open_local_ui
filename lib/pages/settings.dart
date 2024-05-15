import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/providers/locale.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, value, child) => PageBaseLayout(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsPageTitle,
              style: const TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 16.0),
            _buildThemeSettings(context),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 16.0),
            _buildAccessibilitySettings(context),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 16.0),
            _buildOllamaSettings(context),
          ],
        ),
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
        Text(
          AppLocalizations.of(context)!.settingsPageThemeLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 8.0),
        DropdownMenu(
          leadingIcon: const Icon(UniconsLine.moon_eclipse),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          initialSelection: themeModeString,
          dropdownMenuEntries: [
            DropdownMenuEntry(
                value: 'Light',
                label: AppLocalizations.of(context)!.settingsThemeModeLight),
            DropdownMenuEntry(
                value: 'Dark',
                label: AppLocalizations.of(context)!.settingsThemeModeDark),
            DropdownMenuEntry(
                value: 'System',
                label: AppLocalizations.of(context)!.settingsThemeModeSystem),
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

  Widget _buildAccessibilitySettings(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageAccessiblityLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 8.0),
        DropdownMenu(
          leadingIcon: const Icon(UniconsLine.language),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          initialSelection: context.watch<LocaleProvider>().languageCode,
          dropdownMenuEntries: [
            DropdownMenuEntry(
                value: 'en',
                label: AppLocalizations.of(context)!.settingsLanguageEnglish),
            DropdownMenuEntry(
                value: 'es',
                label: AppLocalizations.of(context)!.settingsLanguageSpanish),
            DropdownMenuEntry(
                value: 'fr',
                label: AppLocalizations.of(context)!.settingsLanguageFrench),
            DropdownMenuEntry(
                value: 'de',
                label: AppLocalizations.of(context)!.settingsLanguageDetusche),
            DropdownMenuEntry(
                value: 'it',
                label: AppLocalizations.of(context)!.settingsLanguageItalian),
          ],
          onSelected: (value) {
            context.read<LocaleProvider>().setLocale(value ?? 'en');
          },
        ),
      ],
    );
  }

  Widget _buildOllamaSettings(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageOllamaLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(UniconsLine.processor),
            const Gap(8.0),
            Text(
              '${AppLocalizations.of(context)!.settingsPageOllamaUseGpuLabel}:',
              style: const TextStyle(fontSize: 16.0),
            ),
            const Gap(8.0),
            Switch(
              value: context.watch<ChatProvider>().isOllamaUsingGpu,
              onChanged: (value) {
                context.read<ChatProvider>().ollamaEnableGpu(value);
              },
            ),
            if (!context.watch<ChatProvider>().isOllamaUsingGpu) const Gap(8),
            if (!context.watch<ChatProvider>().isOllamaUsingGpu)
              const Text(
                'Harmful for performance!',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ],
    );
  }
}
