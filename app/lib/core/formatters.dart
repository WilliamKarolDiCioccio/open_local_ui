import 'package:intl/intl.dart';

class Fortmatters {
  static String standardDate(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dateTime);
  }
}
