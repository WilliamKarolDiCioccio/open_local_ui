import 'package:flutter/material.dart';

/// A helper class to serialize and deserialize Color objects to/from JSON.
@immutable
class JsonColorHelper {
  final Color value;

  const JsonColorHelper(this.value);

  // Convenience accessorsì
  int get a => (value.a * 255.0).round().clamp(0, 255);
  int get r => (value.r * 255.0).round().clamp(0, 255);
  int get g => (value.g * 255.0).round().clamp(0, 255);
  int get b => (value.b * 255.0).round().clamp(0, 255);

  /// Parse from "#AARRGGBB" or "#RRGGBB"
  factory JsonColorHelper.fromJson(String hex) {
    final normalized = hex.trim().replaceFirst('#', '');

    if (normalized.length != 6 && normalized.length != 8) {
      throw FormatException('Invalid hex color: $hex');
    }

    final buffer = StringBuffer();
    if (normalized.length == 6) {
      buffer.write('FF'); // default alpha
    }

    buffer.write(normalized);

    final argb = int.parse(buffer.toString(), radix: 16);
    return JsonColorHelper(Color(argb));
  }

  /// Always serialize as "#AARRGGBB"
  String toJson() => '#$a$r$g$b'.toUpperCase();
}
