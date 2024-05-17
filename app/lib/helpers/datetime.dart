class DateTimeHelpers {
  static String getFormattedDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';
  }
}
