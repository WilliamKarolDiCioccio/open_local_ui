import 'package:flutter/material.dart';

/// A helper class for working with colors.
class ColorHelpers {
  /// Converts a hexadecimal color code to a Flutter [Color] object.
  ///
  /// The [hex] parameter should be a string representing a hexadecimal color code,
  /// with or without the '#' symbol.
  ///
  /// Returns a [Color] object representing the converted color.
  static Color colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// Converts a Flutter [Color] object to a hexadecimal color code.
  ///
  /// The [color] parameter should be a [Color] object representing a color.
  ///
  /// Returns a string representing the hexadecimal color code, including the '#' symbol.
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
