import 'package:intl/intl.dart';

class DateTimeHelpers {
  static String formattedDateTime(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dateTime);
  }
}
