import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:discord_rpc/discord_rpc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/backend/private/providers/ollama_api.dart';
import 'package:open_local_ui/backend/private/services/tts.dart';
import 'package:open_local_ui/backend/private/storage/chat_sessions.dart';
import 'package:open_local_ui/backend/private/storage/ollama_models.dart';
import 'package:open_local_ui/constants/assets.dart';
import 'package:open_local_ui/core/asset.dart';
import 'package:open_local_ui/env.dart';
import 'package:open_local_ui/frontend/screens/dashboard.dart';
import 'package:open_local_ui/frontend/screens/onboarding.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatelessWidget {
  final bool userOnboarded;

  const SplashScreen({super.key, required this.userOnboarded});

  Future<void> _preloadAssets() async {
    for (final asset in Assets.all) {
      await AssetManager.loadAsset(
        asset.path,
        source: asset.source,
        type: asset.type,
      );
    }
  }

  /// All loading and initialization code that returns or yields data
  /// needed for the material app or locale provider creation must be placed in the main function.
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // Supabase

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Rive

    await RiveFile.initialize();

    // Discord RPC

    final discordRPCEnabled = prefs.getBool('discordRPCEnabled') ?? false;

    if (discordRPCEnabled) {
      DiscordRPC.initialize();

      final rpc = DiscordRPC(
        applicationId: '1288789740338020392',
      );

      rpc.start(autoRegister: true);
      rpc.updatePresence(
        DiscordPresence(
          state: 'Chatting in OpenLocalUI 🚀',
          details: 'github.com/WilliamKarolDiCioccio/open_local_ui',
          startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    // Dependency injection

    final getIt = GetIt.instance;

    getIt.registerSingleton<OllamaAPIProvider>(OllamaAPIProvider());
    getIt.registerSingleton<TTSService>(TTSService());
    getIt.registerSingleton<ChatSessionsDB>(ChatSessionsDB());
    getIt.registerSingleton<OllamaModelsDB>(OllamaModelsDB());

    await GetIt.instance<OllamaAPIProvider>().startOllama();
    await GetIt.instance<TTSService>().startServer();
    await GetIt.instance<ChatSessionsDB>().init();
    await GetIt.instance<OllamaModelsDB>().init();

    // Preload assets

    await _preloadAssets();
  }

  @override
  Widget build(BuildContext context) {
    final nextScreen =
        userOnboarded ? const DashboardScreen() : const OnboardingScreen();

    return FutureBuilder(
      future: _init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Updating resources...'),
                const Gap(16),
                SpinKitCircle(
                  color: AdaptiveTheme.of(context).mode.isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ],
            ),
          );
        }

        return AnimatedSplashScreen(
          splash: SvgPicture.asset(
            'assets/graphics/logos/open_local_ui.svg',
            width: 512,
            // ignore: deprecated_member_use
            color: Colors.white,
          ),
          nextScreen: nextScreen,
          backgroundColor: AdaptiveTheme.of(context).theme.primaryColor,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.theme,
          duration: 1500,
          animationDuration: const Duration(seconds: 1),
        );
      },
    );
  }
}
