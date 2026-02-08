import 'package:intl/intl.dart';

const _unknownYear = '0000';

/// Parsed date-of-birth parts. [year] is null when unknown (0000).
/// [month] is 1-indexed (1=Jan, 12=Dec).
class DobParts {
  final int? year;
  final int month; // 1-indexed
  final int day;
  const DobParts({this.year, required this.month, required this.day});
}

/// Parse a dateOfBirth string (YYYY-MM-DD) into parts.
DobParts parseDob(String dateOfBirth) {
  final parts = dateOfBirth.split('-');
  final yearStr = parts[0];
  return DobParts(
    year: yearStr == _unknownYear ? null : int.parse(yearStr),
    month: int.parse(parts[1]),
    day: int.parse(parts[2]),
  );
}

/// Build a dateOfBirth string. Pass null for year if unknown.
/// [month] is 1-indexed (1=Jan).
String buildDob(int? year, int month, int day) {
  final y = year != null ? year.toString().padLeft(4, '0') : _unknownYear;
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

bool hasKnownYear(String dateOfBirth) {
  return !dateOfBirth.startsWith('$_unknownYear-');
}

/// Get the next birthday as a DateTime.
DateTime getNextBirthday(String dateOfBirth) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dob = parseDob(dateOfBirth);
  var next = DateTime(today.year, dob.month, dob.day);
  if (next.isBefore(today)) {
    next = DateTime(today.year + 1, dob.month, dob.day);
  }
  return next;
}

/// Days until next birthday. Returns 0 if today is the birthday.
int daysUntilBirthday(String dateOfBirth) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final next = getNextBirthday(dateOfBirth);
  return next.difference(today).inDays;
}

/// Age they'll turn on their next birthday. Null if year unknown.
int? getUpcomingAge(String dateOfBirth) {
  final dob = parseDob(dateOfBirth);
  if (dob.year == null) return null;
  final next = getNextBirthday(dateOfBirth);
  return next.year - dob.year!;
}

/// Current age. Null if year unknown.
int? getCurrentAge(String dateOfBirth) {
  final dob = parseDob(dateOfBirth);
  if (dob.year == null) return null;
  final now = DateTime.now();
  var age = now.year - dob.year!;
  final monthDiff = now.month - dob.month;
  if (monthDiff < 0 || (monthDiff == 0 && now.day < dob.day)) {
    age--;
  }
  return age;
}

/// Whether today is this person's birthday.
bool isBirthdayToday(String dateOfBirth) {
  final now = DateTime.now();
  final dob = parseDob(dateOfBirth);
  return now.month == dob.month && now.day == dob.day;
}

/// Format date for display. Omits year when unknown.
String formatDate(String dateOfBirth) {
  final dob = parseDob(dateOfBirth);
  final d = DateTime(2000, dob.month, dob.day);
  final dayMonth = DateFormat('d MMMM').format(d);
  if (dob.year == null) return dayMonth;
  return '$dayMonth ${dob.year}';
}

/// Get initials from a name (up to 2 characters).
String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
