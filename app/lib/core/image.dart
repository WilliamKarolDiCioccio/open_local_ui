import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Manages the caching of images.
///
/// This class provides methods for caching images into an image pool.
/// The scope of this class is much narrower than the [AssetManager] class, and its not globally available but instead should be instantiated.
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

/// A helper class for working with images.
class ImageHelpers {
  /// Compares two images represented as [Uint8List] objects.
  ///
  /// The [imageBytes1] and [imageBytes2] parameters should be [Uint8List] objects representing the images to be compared.
  ///
  /// Returns a [Future] that resolves to a [bool] indicating whether the images are pixel-perfect identical.
  static Future<bool> compare(
    Uint8List? imageBytes1,
    Uint8List? imageBytes2,
  ) async {
    final img.Image? image1 = img.decodeImage(imageBytes1 ?? Uint8List(0));
    final img.Image? image2 = img.decodeImage(imageBytes2 ?? Uint8List(0));

    if (image1 == null || image2 == null) {
      return false;
    }

    if (image1.width != image2.width || image1.height != image2.height) {
      return false;
    }

    for (int y = 0; y < image1.height; y++) {
      for (int x = 0; x < image1.width; x++) {
        if (image1.getPixel(x, y) != image2.getPixel(x, y)) {
          return false;
        }
      }
    }

    return true;
  }
}
