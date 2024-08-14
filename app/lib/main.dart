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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_theme/system_theme.dart';

void _preloadAssets() async {
  Future.wait(
    [
      AssetManager.loadLocalAsset('assets/metadata/ollama_models.json'),
      AssetManager.loadLocalAsset('assets/graphics/logos/apache.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/arduino.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/bash.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/c.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/clojure.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/cmake.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/cpp.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/crystal.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/cs.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/css.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/dart.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/delphi.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/dockerfile.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/elixir.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/erlang.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/flutter.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/fortran.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/glsl.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/go.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/gradle.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/haskell.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/java.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/javascript.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/json.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/julia.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/kotlin.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/langchain.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/less.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/llvm.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/lua.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/makefile.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/nginx.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/nsis.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/ocaml.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/ollama.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/perl.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/php.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/powershell.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/python.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/ruby.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/rust.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/scala.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/scss.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/supabase.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/swift.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/toml.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/typescript.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/vala.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/xml.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/html.svg'),
      AssetManager.loadLocalAsset('assets/graphics/logos/yaml.svg'),
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

  await ModelProvider.startOllama();
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

  const MyApp({
    super.key,
    required this.themeAccentColor,
    required this.themeMode,
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
    ModelProvider.stopOllama();
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
        home: Stack(
          children: [
            const DashboardScreen(),
            Positioned(
              top: 0.0,
              right: 0.0,
              width: MediaQuery.of(context).size.width,
              height: 32.0,
              child: const WindowManagementBar(),
            ),
          ],
        ),
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }
}

class WindowManagementBar extends StatelessWidget {
  const WindowManagementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Flexible(
            child: MoveWindow(),
          ),
          Row(
            children: [
              MinimizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                  iconMouseOver: Colors.green,
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                  iconMouseOver: Colors.orange,
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                  iconMouseOver: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
