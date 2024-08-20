import 'package:intl/intl.dart';

class FortmatHelpers {
  static String standardDate(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dateTime);
  }
}
