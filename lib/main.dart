import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_theme/system_theme.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/l10n/l10n.dart';
import 'package:open_local_ui/layout/dashboard.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/locale.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:open_local_ui/utils/logger.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await ModelProvider.sServe();
  await ModelProvider.sUpdateList();

  if (defaultTargetPlatform.supportsAccentColor) {
    SystemTheme.fallbackColor = Colors.cyan;
    await SystemTheme.accentColor.load();
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

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

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

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
            const Positioned(
              bottom: 0,
              right: 0,
              child: FeedbackButton(),
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
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: SystemTheme.accentColor.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  void _createGitHubIssue(String text, Uint8List screenshot) async {
    const owner = 'WilliamKarolDiCioccio';
    const repo = 'open_local_ui';

    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/issues');

    final headers = {
      'Authorization': 'token ${Env.gitHubToken}',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28'
    };

    late String deviceInfo;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      final plugin = await DeviceInfoPlugin().windowsInfo;
      deviceInfo = '''- Platfrom: ${plugin.productName}
- Major version: ${plugin.majorVersion}
- Minor version: ${plugin.minorVersion}
- Build number: ${plugin.buildNumber}
- Memory in MB: ${plugin.systemMemoryInMegabytes}''';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      final plugin = await DeviceInfoPlugin().linuxInfo;
      deviceInfo = '''- Platfrom: ${plugin.name} (${plugin.versionCodename})
- Version: ${plugin.version}
- Build number: ${plugin.buildId}''';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final plugin = await DeviceInfoPlugin().macOsInfo;
      deviceInfo = '''- Platfrom: ${plugin.hostName}
- Major version: ${plugin.majorVersion}
- Minor version: ${plugin.minorVersion}
- Patch version: ${plugin.patchVersion}
- Kernel version: ${plugin.kernelVersion}
- Build number: ${plugin.memorySize}
- Model: ${plugin.model}
- Memory in MB: ${plugin.memorySize}''';
    }

    final packageInfo = await PackageInfo.fromPlatform();

    // NOTE: No way to upload images to GitHub API as of now
    // final issueImage = base64.encode(screenshot);

    final issueTextBody = '''$text
\n\n
**App Info**
- Version: ${packageInfo.version}
- Build: ${packageInfo.buildNumber}
\n
**Device Info**
$deviceInfo
\n
\n
This issue was created automatically by the app.''';

    logger.t(issueTextBody);

    final issueBody = jsonEncode({
      'title': 'App reported issue',
      'body': issueTextBody,
      'assignees': ['WilliamKarolDiCioccio'],
      'labels': ['bug'],
    });

    http.post(url, headers: headers, body: issueBody).then((response) {
      if (response.statusCode != 200) {
        logger.e('Failed to create issue. Status code: ${response.body}');
      } else {
        logger.d('Issue created successfully. Issue URL: ${response.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ElevatedButton(
        onPressed: () {
          BetterFeedback.of(context).show(
            (UserFeedback feedback) {
              _createGitHubIssue(
                feedback.text,
                feedback.screenshot,
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(UniconsLine.feedback),
              const SizedBox(width: 8.0),
              Text(AppLocalizations.of(context)!.feedbackButton),
            ],
          ),
        ),
      ),
    );
  }
}
