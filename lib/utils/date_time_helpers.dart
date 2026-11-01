import 'package:intl/intl.dart';

/// Date and time formatting helpers.
class DateTimeHelpers {
  /// Format time as "HH:mm" (e.g., "14:30").
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format time as "h:mm a" (e.g., "2:30 PM").
  static String formatTime12h(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format hour as "ha" (e.g., "2PM").
  static String formatHour(DateTime dateTime) {
    return DateFormat('ha').format(dateTime);
  }

  /// Format date as "EEEE, d MMMM" (e.g., "Monday, 26 October").
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM').format(dateTime);
  }

  /// Format day name short (e.g., "Mon").
  static String formatDayShort(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }

  /// Format day name full (e.g., "Monday").
  static String formatDayFull(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  /// Format date short (e.g., "26 Oct").
  static String formatDateShort(DateTime dateTime) {
    return DateFormat('d MMM').format(dateTime);
  }

  /// Check if the given date is today.
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Get the current local time adjusted for UTC offset.
  static DateTime getLocalTime(double utcOffsetSeconds) {
    final now = DateTime.now().toUtc();
    return now.add(Duration(seconds: utcOffsetSeconds.toInt()));
  }
}
