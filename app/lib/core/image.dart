import 'dart:typed_data';
import 'package:image/image.dart' as img;

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

class ImageHelpers {
  static Future<bool> compare(
      Uint8List? imageBytes1, Uint8List? imageBytes2) async {
    img.Image? image1 = img.decodeImage(imageBytes1 ?? Uint8List(0));
    img.Image? image2 = img.decodeImage(imageBytes2 ?? Uint8List(0));

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
