import 'package:intl/intl.dart';

/// Get today's day abbreviation (Sun, Mon, Tue, etc.)
String todayAbbrev() {
  final wd = DateTime.now().weekday; // 1=Mon .. 7=Sun
  switch (wd) {
    case DateTime.sunday:
      return 'Sun';
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    default:
      return 'Sun';
  }
}

/// Get day abbreviation from day index (0=Sun, 1=Mon, etc.)
String dayAbbrevFromIndex(int index) {
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return days[index % 7];
}

/// Format date time to readable string
String formatDateTime(String dateTimeStr) {
  try {
    final dt = DateTime.parse(dateTimeStr);
    return DateFormat.yMMMEd().add_jm().format(dt);
  } catch (e) {
    return dateTimeStr;
  }
}

/// Format time range
String formatTimeRange(String start, String end) {
  return '$start - $end';
}
