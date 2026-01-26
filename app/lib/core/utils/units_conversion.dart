import 'dart:math';

/// Utility class for unit conversions, specifically for digital storage units.
class UnitsConversionUtils {
  // Constants for Digital Storage
  static const int _k = 1024;
  static const int bytesInKb = _k;
  static const int bytesInMb = _k * _k;
  static const int bytesInGb = _k * _k * _k;

  /// Converts any value to Bytes for easier math
  static double toBytes(double value, StorageUnit unit) {
    switch (unit) {
      case StorageUnit.byte:
        return value;
      case StorageUnit.kb:
        return value * bytesInKb;
      case StorageUnit.mb:
        return value * bytesInMb;
      case StorageUnit.gb:
        return value * bytesInGb;
    }
  }

  /// Converts bytes to a target unit
  static double fromBytes(double bytes, StorageUnit targetUnit) {
    switch (targetUnit) {
      case StorageUnit.byte:
        return bytes;
      case StorageUnit.kb:
        return bytes / bytesInKb;
      case StorageUnit.mb:
        return bytes / bytesInMb;
      case StorageUnit.gb:
        return bytes / bytesInGb;
    }
  }

  /// One-stop shop for all combinations:
  /// Usage: convert(1, from: StorageUnit.gb, to: StorageUnit.mb) -> 1024.0
  static double convert(
    double value, {
    required StorageUnit from,
    required StorageUnit to,
  }) {
    if (from == to) return value;
    final bytes = toBytes(value, from);
    return fromBytes(bytes, to);
  }

  /// Returns a human-readable string (e.g., "1.52 GB")
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return "${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}

enum StorageUnit { byte, kb, mb, gb }
