import 'dart:typed_data';

/// Manages the caching of images.
///
/// This class provides methods for caching images into an image pool.
/// The scope of this class is much narrower than the [AssetsManager] class, and its not globally available but instead should be instantiated.
/// We're evauluating the option to merge the two classes into one.
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;

  ImageCacheManager._internal();

  final Map<String, Uint8List?> _cache = {};

  void cacheImage(String key, Uint8List? imageBytes) {
    _cache[key] = imageBytes;
  }

  Uint8List? getImage(String key) {
    return _cache[key];
  }

  void clearCache() {
    _cache.clear();
  }
}
