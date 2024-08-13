import 'package:flutter/services.dart';
import 'package:open_local_ui/core/logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum AssetSource { local, remote }

enum AssetType { text, image, audio, video, binary }

class AssetManager {
  static final Map<String, dynamic> _assetRegistry = {};

  static Future<String> loadLocalAsset(String assetPath) async {
    final assetContent = await rootBundle.loadString(assetPath);
    _assetRegistry[assetPath] = assetContent;
    logger.d('Loaded asset: $assetPath');
    return assetContent;
  }

  static Future<void> saveToPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    logger.d('Saved to preferences: $key');
    await prefs.setString(key, value);
  }

  static Future<String?> getFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    logger.d('Retrieved from preferences: $key');
    return prefs.getString(key);
  }

  static dynamic getAsset(String key) {
    logger.d('Retrieved asset: $key');
    return _assetRegistry[key];
  }

  static void unloadAsset(String key) {
    logger.d('Unloaded asset: $key');
    _assetRegistry.remove(key);
  }

  static void clearAssets() {
    logger.d('Cleared all assets');
    _assetRegistry.clear();
  }
}
