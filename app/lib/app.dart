import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/core/constants/flutter.dart';
import 'package:open_local_ui/core/constants/languages.dart';
import 'package:open_local_ui/core/providers/locale.dart';
import 'package:open_local_ui/core/providers/ollama_api.dart';
import 'package:open_local_ui/core/repositories/chat_sessions.dart';
import 'package:open_local_ui/core/repositories/ollama_models.dart';
import 'package:open_local_ui/features/onboarding/presentation/screens/splash.dart';
import 'package:open_local_ui/localization/app_localizations.dart';
import 'package:provider/provider.dart';

class OpenLocalUIApp extends StatefulWidget {
  final Color themeAccentColor;
  final AdaptiveThemeMode themeMode;
  final bool userOnboarded;

  const OpenLocalUIApp({
    super.key,
    required this.themeAccentColor,
    required this.themeMode,
    required this.userOnboarded,
  });

  @override
  State<OpenLocalUIApp> createState() => _OpenLocalUIAppState();
}

class _OpenLocalUIAppState extends State<OpenLocalUIApp> {
  @override
  void dispose() {
    GetIt.instance<ChatSessionsDB>().deinit();
    GetIt.instance<OllamaModelsDB>().deinit();
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
          FormBuilderLocalizations.delegate,
        ],
        home: SplashScreen(userOnboarded: widget.userOnboarded),
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }
}
