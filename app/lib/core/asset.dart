import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:open_local_ui/core/http.dart';
import 'package:open_local_ui/core/logger.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AssetSource {
  local,
  remote,
}

enum AssetType {
  raw,
  json,
  binary,
  rivefile,
}

/// Manages the assets used in the application.
///
/// The [AssetManager] class provides methods for caching assets into an asset pool,
/// this way assets can be loaded from memory instead of the file system or network,
/// thefore gratly improving performance.
///
/// NOTE: The pool is most effective with small sized and frequently accessed assets.
class AssetManager {
  static final Map<String, dynamic> _assetRegistry = {};

  /// Wapper around [SharedPreferences] to save a key-value pair to the device's preferences.
  ///
  /// The [key] parameter should be a string representing the key of the value to be saved.
  /// The [value] parameter should be a string representing the value to be saved.
  ///
  /// The method returns a [Future] that resolves to void.
  static Future<void> saveToPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    logger.d('Saved to preferences: $key');
    await prefs.setString(key, value);
  }

  /// Wapper around [SharedPreferences] to retrieve a value from the device's preferences.
  ///
  /// The [key] parameter should be a string representing the key of the value to be retrieved.
  ///
  /// The method returns a [Future] that resolves to the specified value type.
  static Future<T?> getFromPreferences<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    logger.d('Retrieved from preferences: $key');
    if (T is String) {
      return prefs.getString(key) as T?;
    } else if (T is int) {
      return prefs.getInt(key) as T?;
    } else if (T is double) {
      return prefs.getDouble(key) as T?;
    } else if (T is bool) {
      return prefs.getBool(key) as T?;
    } else {
      throw Exception('Invalid value type');
    }
  }

  /// Retrieves an asset from the asset pool in JSON format.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be retrieved.
  ///
  /// The method returns a [Map] that represents the asset in JSON format.
  static Map<String, dynamic> _getAssetAsJson(String key) {
    return _getRawAsset(key) as Map<String, dynamic>;
  }

  /// Retrieves an asset from the asset pool in the binary format.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be retrieved.
  ///
  /// The method returns a [Uint8List] that represents the asset in binary format.
  static Uint8List _getAssetAsBytes(String key) {
    return (_getRawAsset(key) as ByteData).buffer.asUint8List();
  }

  /// Retrieves an asset from the asset pool in plain text format.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be retrieved.
  ///
  /// The method returns a [String] that represents the asset in plain text format.
  static dynamic _getRawAsset(String key) {
    return _assetRegistry[key];
  }

  /// Retrieves an asset from the asset pool in the RiveFile format.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be retrieved.
  ///
  /// The method returns a [RiveFile] that represents the asset in RiveFile format.
  static RiveFile _getAssetAsRiveFile(String key) {
    return _getRawAsset(key) as RiveFile;
  }

  static dynamic getAsset(
    String key, {
    required AssetType type,
  }) {
    switch (type) {
      case AssetType.raw:
        return _getRawAsset(key);
      case AssetType.json:
        return _getAssetAsJson(key);
      case AssetType.binary:
        return _getAssetAsBytes(key);
      case AssetType.rivefile:
        return _getAssetAsRiveFile(key);
      default:
        throw Exception('Invalid asset type');
    }
  }

  /// Checks if an asset is loaded in the asset pool.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be checked.
  ///
  /// The method returns a boolean value.
  static bool isAssetLoaded(String key) {
    return _assetRegistry.containsKey(key);
  }

  /// Loads an asset from local storage or network and caches it into the asset pool.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be loaded.
  /// The [source] parameter should be an [AssetSource] enum representing the source of the asset.
  /// The [type] parameter should be an [AssetType] enum representing the type of the asset.
  /// The [forceReload] parameter should be a boolean value indicating if the asset should be reloaded if it already exists in the pool.
  ///
  /// The method returns a [Future] that resolves to the asset content in plain text format.
  static Future<dynamic> loadAsset(
    String key, {
    required AssetSource source,
    AssetType type = AssetType.raw,
    bool forceReload = false,
  }) async {
    if (!isAssetLoaded(key) || (isAssetLoaded(key) && forceReload)) {
      late dynamic assetContent;

      switch (source) {
        case AssetSource.local:
          switch (type) {
            case AssetType.raw:
              assetContent = await rootBundle.loadString(key);
              break;
            case AssetType.json:
              assetContent = jsonDecode(await rootBundle.loadString(key));
              break;
            case AssetType.binary:
              assetContent = await rootBundle.load(key);
              break;
            case AssetType.rivefile:
              assetContent = RiveFile.import(await rootBundle.load(key));
              break;
            default:
              throw Exception('Invalid asset type');
          }
          break;
        case AssetSource.remote:
          assetContent = await HTTPHelpers.get(key).then(
            (response) => response.body,
          );
          break;
        default:
          throw Exception('Invalid asset source');
      }

      _assetRegistry[key] = assetContent;
      logger.d('Loaded asset: $key');

      return assetContent;
    } else {
      return getAsset(key, type: type)!;
    }
  }

  /// Unloads an asset from the asset pool.
  ///
  /// The [key] parameter should be a string representing the path of the asset to be unloaded.
  ///
  /// The method returns void.
  static void unloadAsset(String key) {
    logger.d('Unloaded asset: $key');
    _assetRegistry.remove(key);
  }

  /// Clears all assets from the asset pool.
  ///
  /// The method returns void.
  static void clearAssets() {
    logger.d('Cleared all assets');
    _assetRegistry.clear();
  }
}
