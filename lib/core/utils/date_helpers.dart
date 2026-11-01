/// "2026-11-01" - the key used to store a completed day.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime daysAgo(DateTime from, int n) => DateTime(from.year, from.month, from.day - n);

const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
String weekdayLetter(DateTime d) => _weekdays[d.weekday - 1];

const _longDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String prettyDate(DateTime d) => '${_longDays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}
