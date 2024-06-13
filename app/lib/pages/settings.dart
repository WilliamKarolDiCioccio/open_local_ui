import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/locale.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

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
            const ThemeSettings(),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 16.0),
            const AccessibilitySettings(),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 16.0),
            const OllamaSettings(),
          ],
        ),
      ),
    );
  }
}

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
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
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageThemeLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Gap(16.0),
        DropdownMenu(
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
}

class AccessibilitySettings extends StatelessWidget {
  const AccessibilitySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageAccessiblityLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Gap(16.0),
        DropdownMenu(
          menuHeight: 256,
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
}

class OllamaSettings extends StatefulWidget {
  const OllamaSettings({super.key});

  @override
  State<OllamaSettings> createState() => _OllamaSettingsState();
}

class _OllamaSettingsState extends State<OllamaSettings> {
  double _temperature = 0.0;
  double _keepAliveTime = 0;

  @override
  void initState() {
    super.initState();

    _temperature = context.read<ChatProvider>().temperature;
    _keepAliveTime = context.read<ChatProvider>().keepAliveTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageOllamaLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Gap(16.0),
        FractionallySizedBox(
          widthFactor: 0.6,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(UniconsLine.processor),
                  const Gap(8.0),
                  Text(
                    '${AppLocalizations.of(context)!.settingsPageOllamaUseGPULabel}:',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const Gap(8.0),
                  Switch(
                    value: context.watch<ChatProvider>().isOllamaUsingGpu,
                    onChanged: !context.watch<ChatProvider>().isGenerating
                        ? (value) {
                            if (!value) {
                              SnackBarHelpers.showSnackBar(
                                AppLocalizations.of(context)!
                                    .ollamaDisabledGPUWarningSnackbarText,
                                SnackBarType.warning,
                              );
                            }

                            context.read<ChatProvider>().enableGPU(value);
                          }
                        : null,
                  ),
                ],
              ),
              const Gap(16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(UniconsLine.temperature),
                  const Gap(8.0),
                  Text(
                    '${AppLocalizations.of(context)!.settingsPageOllamaSetTemperatureLabel}:',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const Gap(8.0),
                  Slider(
                    value: _temperature,
                    onChangeEnd: (value) {
                      context.read<ChatProvider>().setTemperature(_temperature);
                    },
                    onChanged: !context.watch<ChatProvider>().isGenerating
                        ? (value) {
                            setState(() {
                              _temperature = value;
                            });
                          }
                        : null,
                    min: 0,
                    max: 1,
                  ),
                  const Gap(8.0),
                  Text(
                    '${(_temperature * 100).round()}%',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              const Gap(16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(UniconsLine.clock),
                  const Gap(8.0),
                  Text(
                    '${AppLocalizations.of(context)!.settingsPageOllamaSetKeepAliveTimeLabel}:',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const Gap(8.0),
                  Slider(
                    value: _keepAliveTime,
                    onChangeEnd: (value) {
                      context.read<ChatProvider>().setKeepAliveTime(
                            _keepAliveTime == 61 ? -1 : _keepAliveTime.toInt(),
                          );
                    },
                    onChanged: !context.watch<ChatProvider>().isGenerating
                        ? (value) {
                            setState(() {
                              _keepAliveTime = value;
                            });
                          }
                        : null,
                    min: 0,
                    max: 61,
                  ),
                  const Gap(8.0),
                  Text(
                    '${_keepAliveTime == 61 ? '∞' : _keepAliveTime.round()} min',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
