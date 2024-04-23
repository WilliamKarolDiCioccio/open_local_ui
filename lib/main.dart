import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import 'package:open_local_ui/layout/dashboard.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await ModelProvider.sServe();
  await ModelProvider.sUpdateList();

  if (defaultTargetPlatform.supportsAccentColor) {
    SystemTheme.fallbackColor = Colors.cyan;
    await SystemTheme.accentColor.load();
  }

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider<ModelProvider>(
          create: (context) => ModelProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
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

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

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
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      debugShowFloatingThemeButton: false,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'OpenLocalUI',
        theme: theme,
        darkTheme: darkTheme,
        home: Stack(
          children: [
            const DashboardLayout(),
            Positioned(
              top: 0.0,
              right: 0.0,
              width: MediaQuery.of(context).size.width,
              height: 32.0,
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    Flexible(
                      child: MoveWindow(),
                    ),
                    Row(
                      children: [
                        MinimizeWindowButton(),
                        MaximizeWindowButton(),
                        CloseWindowButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }
}
