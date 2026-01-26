import 'package:discord_rpc/discord_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_local_ui/bootstrap/env.dart';
import 'package:open_local_ui/core/assets_manager.dart';
import 'package:open_local_ui/core/constants/assets.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/providers/ollama_api.dart';
import 'package:open_local_ui/core/repositories/chat_sessions.dart';
import 'package:open_local_ui/core/repositories/ollama_models.dart';
import 'package:open_local_ui/core/services/tts.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  Future<BootstrapResult> create() async {
    try {
      // 0. Flutter Binding
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Logging
      await AppLogger().init();

      // 1. Core Services
      final prefs = await SharedPreferences.getInstance();

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabasePublishableKey,
      );

      await rive.RiveNative.init();

      // 2. Dependency Injection
      _setupDependencyInjection();

      // 3. Service-specific initialization
      await _initAppServices(prefs);

      // 4. Asset Preloading
      await _preloadAssets();

      // Return success data
      final userOnboarded = prefs.getBool('userOnboarded') ?? false;
      return BootstrapResult.success(userOnboarded: userOnboarded);
    } catch (e, stack) {
      appLogger.e('Bootstrap Error: $e');
      appLogger.i(stack.toString());
      return BootstrapResult.error(e.toString());
    }
  }

  void _setupDependencyInjection() {
    final getIt = GetIt.instance;
    getIt.registerSingleton<OllamaAPIProvider>(OllamaAPIProvider());
    getIt.registerSingleton<ChatSessionsDB>(ChatSessionsDB());
    getIt.registerSingleton<OllamaModelsDB>(OllamaModelsDB());
    getIt.registerSingleton<TTSService>(TTSService());
  }

  Future<void> _initAppServices(SharedPreferences prefs) async {
    // Discord RPC
    DiscordRPC.initialize();
    if (prefs.getBool('discordRPCEnabled') ?? false) {
      final rpc = DiscordRPC(applicationId: Env.discordClientId);
      rpc.start(autoRegister: true);
      rpc.updatePresence(
        DiscordPresence(
          state: 'Chatting in OpenLocalUI 🚀',
          details: 'github.com/WilliamKarolDiCioccio/open_local_ui',
          startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    // Database / API Inits
    await GetIt.I<OllamaAPIProvider>().startOllama();
    await GetIt.I<ChatSessionsDB>().init();
    await GetIt.I<OllamaModelsDB>().init();
  }

  Future<void> _preloadAssets() async {
    for (final asset in Assets.all) {
      await AssetsManager.loadAsset(
        asset.path,
        source: asset.source,
        type: asset.type,
      );
    }
  }
}

/// Simple class to hold the result of the bootstrap
class BootstrapResult {
  final bool userOnboarded;
  final String? error;
  final bool hasError;

  BootstrapResult.success({required this.userOnboarded})
    : error = null,
      hasError = false;
  BootstrapResult.error(this.error) : userOnboarded = false, hasError = true;
}
