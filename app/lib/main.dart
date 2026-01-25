import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:feedback/feedback.dart';
import 'package:open_local_ui/app.dart';
import 'package:open_local_ui/bootstrap/app_bootstrap.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/providers/locale.dart';
import 'package:open_local_ui/core/constants/constants.dart';
import 'package:open_local_ui/core/utils/json_extensions.dart';
import 'package:open_local_ui/shared/widgets/bootstrap_error.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  final bootstrap = AppBootstrap();
  final result = await bootstrap.create();

  if (result.hasError) {
    runApp(BootstrapErrorWidget(error: result.error));
    return;
  }

  // Setup theme accent color syncing with system

  final prefs = await SharedPreferences.getInstance();

  if (defaultTargetPlatform.supportsAccentColor) {
    await SystemTheme.accentColor.load();

    SystemTheme.onChange.listen((event) {
      if (prefs.getBool('sync_accent_color') ?? false) {
        AdaptiveTheme.of(scaffoldMessengerKey.currentContext!).setTheme(
          light: ThemeData(
            fontFamily: 'ValeraRound',
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: event.accent,
          ),
          dark: ThemeData(
            fontFamily: 'ValeraRound',
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: event.accent,
          ),
        );

        appLogger.i('System accent color changed: ${event.accent}');
      }
    });
  }

  late Color themeAccentColor;

  if ((prefs.getBool('sync_accent_color') ?? false) == false) {
    themeAccentColor = JSONColor.fromJson(
      prefs.getString('accent_color') ?? Colors.cyan.toJson(Colors.cyan),
    );
  } else {
    themeAccentColor = SystemTheme.accentColor.accent;
  }

  // Get saved theme mode

  final themeMode =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.light;

  // User configuration

  final userOnboarded = prefs.getBool('userOnboarded') ?? false;

  if (!userOnboarded) {
    await prefs.setBool('userOnboarded', true);
  }

  // Run app

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(
          create: (context) => LocaleProvider(),
        ),
      ],
      child: BetterFeedback(
        theme: FeedbackThemeData(),
        child: OpenLocalUIApp(
          themeAccentColor: themeAccentColor,
          themeMode: themeMode,
          userOnboarded: kDebugMode ? false : userOnboarded,
        ),
      ),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(1280, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'OpenLocalUI';
    appWindow.show();
  });
}
