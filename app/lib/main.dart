import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:feedback/feedback.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:open_local_ui/backend/databases/chat_sessions.dart';
import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/backend/providers/locale.dart';
import 'package:open_local_ui/backend/providers/model.dart';
import 'package:open_local_ui/backend/services/tts.dart';
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/constants/languages.dart';
import 'package:open_local_ui/core/asset.dart';
import 'package:open_local_ui/core/color.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/screens/onboarding.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_theme/system_theme.dart';

void _preloadAssets() async {
  Future.wait(
    [
      AssetManager.loadAsset('assets/graphics/animations/gpu.riv',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/animations/human.riv',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/metadata/ollama_models.json',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/apache.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/arduino.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/bash.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/c.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/clojure.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/cmake.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/cpp.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/crystal.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/cs.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/css.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/dart.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/delphi.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/dockerfile.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/elixir.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/erlang.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/flutter.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/fortran.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/glsl.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/go.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/gradle.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/haskell.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/java.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/javascript.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/json.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/julia.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/kotlin.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/langchain.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/less.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/llvm.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/lua.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/makefile.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/nginx.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/nsis.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/ocaml.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/ollama.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/perl.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/php.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/powershell.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/python.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/ruby.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/rust.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/scala.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/scss.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/supabase.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/swift.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/toml.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/typescript.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/vala.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/xml.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/html.svg',
          source: AssetSource.local),
      AssetManager.loadAsset('assets/graphics/logos/yaml.svg',
          source: AssetSource.local),
    ],
  ).then((_) {
    logger.i('Assets preloaded');
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Internal services

  await initLogger();

  await ModelProvider.startOllamaStatic();
  await TTSService.startServer();
  await ChatSessionsDatabase.init();

  // Backend services

  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Preload assets

  _preloadAssets();

  RiveFile.initialize();

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
    prefs.setBool('userOnboarded', true);
  }

  FlutterNativeSplash.remove();

  // Run app

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(
          create: (context) => LocaleProvider(),
        ),
        ChangeNotifierProvider<ModelProvider>(
          create: (context) => ModelProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    TTSService.stopServer();
    ModelProvider.stopOllamaStatic();
    ChatSessionsDatabase.deinit();

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
        supportedLocales: L10n.all,
        locale: context.watch<LocaleProvider>().locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: widget.userOnboarded
            ? const DashboardScreen()
            : const OnboardingScreen(),
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }
}
