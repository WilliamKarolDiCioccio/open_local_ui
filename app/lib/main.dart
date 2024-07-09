import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:open_local_ui/backend/databases/chat_sessions.dart';
import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/backend/providers/locale.dart';
import 'package:open_local_ui/backend/providers/model.dart';
import 'package:open_local_ui/backend/services/tts.dart';
import 'package:open_local_ui/constants/flutter.dart';
import 'package:open_local_ui/constants/languages.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (defaultTargetPlatform.supportsAccentColor) {
    SystemTheme.fallbackColor = Colors.cyan;
    await SystemTheme.accentColor.load();
  }

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await initLogger();

  await ModelProvider.startOllama();
  await TTSService.startServer();
  await ChatSessionsDatabase.init();

  FlutterNativeSplash.remove();

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
        child: MyApp(savedThemeMode: savedThemeMode),
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
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

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
        colorSchemeSeed: SystemTheme.accentColor.accent,
      ),
      dark: ThemeData(
        fontFamily: 'ValeraRound',
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: SystemTheme.accentColor.accent,
      ),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      debugShowFloatingThemeButton: false,
      builder: (theme, darkTheme) => MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'OpenLocalUI',
        theme: theme,
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
            const DashboardLayout(),
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
