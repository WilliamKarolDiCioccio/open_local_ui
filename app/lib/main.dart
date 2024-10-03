import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:feedback/feedback.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/backend/private/providers/locale.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:open_local_ui/backend/private/services/tts.dart';
import 'package:open_local_ui/backend/private/storage/chat_sessions.dart';
import 'package:open_local_ui/backend/private/storage/ollama_models.dart';
import 'package:open_local_ui/constants/constants.dart';
import 'package:open_local_ui/core/color.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/frontend/screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  /// All loading and initialization code that does not return or yield data
  /// needed for the material app or locale provider creation must be placed in the splash screen.

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Debugging and tracing

  await initLogger();

  // Theme

  if (defaultTargetPlatform.supportsAccentColor) {
    await SystemTheme.accentColor.load();
  }

  late Color themeAccentColor;

  if ((prefs.getBool('sync_accent_color') ?? false) == false) {
    themeAccentColor = ColorHelpers.colorFromHex(
      prefs.getString('accent_color') ?? Colors.cyan.hex,
    );
  } else {
    themeAccentColor = SystemTheme.accentColor.accent;
  }

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
        child: MyApp(
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

class MyApp extends StatefulWidget {
  final Color themeAccentColor;
  final AdaptiveThemeMode themeMode;
  final bool userOnboarded;

  const MyApp({
    super.key,
    required this.themeAccentColor,
    required this.themeMode,
    required this.userOnboarded,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    GetIt.instance<ChatSessionsDB>().deinit();
    GetIt.instance<OllamaModelsDB>().deinit();
    GetIt.instance<TTSService>().stopServer();
    GetIt.instance<OllamaAPIProvider>().stopOllama();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: widget.themeAccentColor,
      ),
      dark: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: widget.themeAccentColor,
      ),
      initial: widget.themeMode,
      debugShowFloatingThemeButton: false,
      builder: (lightTheme, darkTheme) => MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'OpenLocalUI',
        theme: lightTheme,
        darkTheme: darkTheme,
        supportedLocales: languages,
        locale: context.watch<LocaleProvider>().locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(userOnboarded: widget.userOnboarded),
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }
}
