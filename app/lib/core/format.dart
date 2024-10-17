import 'package:intl/intl.dart';

/// A helper class for working with date, time, number, units of measure... formats.
class FormatHelpers {
  /// Formats the given [dateTime] into a standard date string.
  ///
  /// Returns a string representation of the [dateTime] in the format: "dd/MM/yyyy HH:mm:ss".
  static String standardDate(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dateTime);
  }
}
