// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as fcp;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/backend/private/providers/locale.dart';
import 'package:open_local_ui/core/color.dart';
import 'package:open_local_ui/frontend/dialogs/color_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
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
      builder: (context, value, child) => ListView(
        scrollDirection: Axis.vertical,
        children: [
          Text(
            AppLocalizations.of(context).settingsPageTitle,
            textAlign: TextAlign.center,
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
          const DebigSettings(),
        ],
      ),
    );
  }
}

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  Future<bool> _isAccentSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sync_accent_color') ?? false;
  }

  Future<Color> _getAccent() async {
    final prefs = await SharedPreferences.getInstance();
    return ColorHelpers.colorFromHex(
      prefs.getString('accent_color') ?? Colors.cyan.hex,
    );
  }

  void _setAccent(BuildContext context, Color color) {
    AdaptiveTheme.of(context).setTheme(
      light: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: color,
      ),
      dark: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: color,
      ),
    );

    setState(() {});
  }

  String _getThemeModeString(BuildContext context) {
    switch (AdaptiveTheme.of(context).mode) {
      case AdaptiveThemeMode.light:
        return 'Light';
      case AdaptiveThemeMode.dark:
        return 'Dark';
      case AdaptiveThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).settingsPageThemeLabel,
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
          initialSelection: _getThemeModeString(context),
          dropdownMenuEntries: [
            DropdownMenuEntry(
              value: 'Light',
              label: AppLocalizations.of(context).settingsThemeModeLight,
            ),
            DropdownMenuEntry(
              value: 'Dark',
              label: AppLocalizations.of(context).settingsThemeModeDark,
            ),
            DropdownMenuEntry(
              value: 'System',
              label: AppLocalizations.of(context).settingsThemeModeSystem,
            ),
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
        const Gap(16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(UniconsLine.brush_alt),
            const Gap(8.0),
            Text(
              AppLocalizations.of(context).settingsPageAccentColorLabel,
              style: const TextStyle(fontSize: 16.0),
            ),
            const Gap(8.0),
            GestureDetector(
              onTap: () async {
                await showColorPickerDialog(
                  context,
                  await _getAccent(),
                ).then(
                  (color) async {
                    if (color == null) return;

                    final prefs = await SharedPreferences.getInstance();

                    if ((prefs.getBool('sync_accent_color') ?? false) ==
                        false) {
                      _setAccent(context, color);
                    } else {
                      setState(() {});
                    }

                    await prefs.setString(
                      'accent_color',
                      ColorHelpers.colorToHex(color),
                    );
                  },
                );
              },
              child: FutureBuilder(
                future: _getAccent(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SpinKitCircle(
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.white
                          : Colors.black,
                    );
                  } else {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: snapshot.data!,
                    );
                  }
                },
              ),
            ),
            const Gap(16.0),
            const Icon(UniconsLine.sync),
            const Gap(8.0),
            Text(
              AppLocalizations.of(context).settingsPageSyncAccentColorLabel,
              style: const TextStyle(fontSize: 16.0),
            ),
            const Gap(8.0),
            FutureBuilder(
              future: _isAccentSynced(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitCircle(
                    color: AdaptiveTheme.of(context).mode.isDark
                        ? Colors.white
                        : Colors.black,
                  );
                } else {
                  return Switch(
                    value: snapshot.data!,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();

                      if (value) {
                        await prefs.setBool('sync_accent_color', true);
                        _setAccent(
                          context,
                          SystemTheme.accentColor.accent,
                        );
                      } else {
                        final savedColorCode = prefs.getString('accent_color');
                        await prefs.setBool('sync_accent_color', false);

                        _setAccent(
                          context,
                          ColorHelpers.colorFromHex(
                            savedColorCode ?? Colors.cyan.hex,
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
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
          AppLocalizations.of(context).settingsPageAccessibilityLabel,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Gap(16.0),
        DropdownMenu(
          enableFilter: true,
          enableSearch: true,
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
          initialSelection: context.watch<LocaleProvider>().languageSetting,
          dropdownMenuEntries: [
            DropdownMenuEntry(
              value: LocaleProvider.systemLangCode,
              label: AppLocalizations.of(context).settingsLanguageSystem,
            ),
            const DropdownMenuEntry(
              value: 'en',
              label: 'English',
            ),
            const DropdownMenuEntry(
              value: 'es',
              label: 'Spanish',
            ),
            const DropdownMenuEntry(
              value: 'fr',
              label: 'French',
            ),
            const DropdownMenuEntry(
              value: 'de',
              label: 'German',
            ),
            const DropdownMenuEntry(
              value: 'it',
              label: 'Italian',
            ),
            const DropdownMenuEntry(
              value: 'ja',
              label: 'Japanese',
            ),
            const DropdownMenuEntry(
              value: 'ko',
              label: 'Korean',
            ),
            const DropdownMenuEntry(
              value: 'pt',
              label: 'Portuguese',
            ),
            const DropdownMenuEntry(
              value: 'ru',
              label: 'Russian',
            ),
            const DropdownMenuEntry(
              value: 'zh',
              label: 'Chinese',
            ),
            const DropdownMenuEntry(
              value: 'ar',
              label: 'Arabic',
            ),
            const DropdownMenuEntry(
              value: 'hi',
              label: 'Hindi',
            ),
          ],
          onSelected: (value) {
            context
                .read<LocaleProvider>()
                .setLanguage(value ?? LocaleProvider.systemLangCode);
          },
        ),
      ],
    );
  }
}

class DebigSettings extends StatefulWidget {
  const DebigSettings({super.key});

  @override
  State<DebigSettings> createState() => _DebigSettingsState();
}

class _DebigSettingsState extends State<DebigSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).settingsPageDebugLabel,
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
                  const Icon(UniconsLine.calculator),
                  const Gap(8.0),
                  Text(
                    '${AppLocalizations.of(context).settingsPageDebugShowStatistics}:',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const Gap(8.0),
                  Switch(
                    value: context.watch<ChatProvider>().isChatShowStatistics,
                    onChanged: (value) =>
                        context.read<ChatProvider>().enableStatistics(value),
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
