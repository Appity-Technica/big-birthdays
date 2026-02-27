import 'package:intl/intl.dart';

const _unknownYear = '0000';

/// Parsed date-of-birth components.
///
/// A year of `0000` in the raw string is represented as a `null` [year],
/// indicating that the birth year is unknown. [month] is 1-indexed
/// (1 = January, 12 = December).
class DobParts {
  /// The birth year, or `null` when the year is unknown (stored as `0000`).
  final int? year;

  /// The birth month, 1-indexed (1 = January).
  final int month; // 1-indexed

  /// The birth day of the month.
  final int day;
  const DobParts({this.year, required this.month, required this.day});
}

/// Parses a [dateOfBirth] string in `YYYY-MM-DD` format into [DobParts].
///
/// A year of `0000` is treated as an unknown year and returned as `null`
/// in [DobParts.year].
DobParts parseDob(String dateOfBirth) {
  final parts = dateOfBirth.split('-');
  final yearStr = parts[0];
  return DobParts(
    year: yearStr == _unknownYear ? null : int.parse(yearStr),
    month: int.parse(parts[1]),
    day: int.parse(parts[2]),
  );
}

/// Builds a `YYYY-MM-DD` date-of-birth string from individual components.
///
/// Pass `null` for [year] when the birth year is unknown; the string will
/// use `0000` as the year placeholder. [month] is 1-indexed (1 = January).
String buildDob(int? year, int month, int day) {
  final y = year != null ? year.toString().padLeft(4, '0') : _unknownYear;
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Returns `true` if the [dateOfBirth] string has a known birth year
/// (i.e. does not start with `0000-`).
bool hasKnownYear(String dateOfBirth) {
  return !dateOfBirth.startsWith('$_unknownYear-');
}

/// Returns the [DateTime] of the next occurrence of this birthday.
///
/// If the birthday has not yet occurred this calendar year, returns this
/// year's date; otherwise returns next year's date. The returned time
/// is midnight (00:00:00).
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

/// Returns the number of days until the next birthday.
///
/// Returns `0` if today is the birthday.
int daysUntilBirthday(String dateOfBirth) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final next = getNextBirthday(dateOfBirth);
  return next.difference(today).inDays;
}

/// Returns the age the person will turn on their next birthday.
///
/// Returns `null` if the birth year is unknown (`0000`).
int? getUpcomingAge(String dateOfBirth) {
  final dob = parseDob(dateOfBirth);
  if (dob.year == null) return null;
  final next = getNextBirthday(dateOfBirth);
  return next.year - dob.year!;
}

/// Returns the person's current age in whole years.
///
/// Accounts for whether the birthday has occurred yet this year.
/// Returns `null` if the birth year is unknown (`0000`).
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

/// Returns `true` if today is this person's birthday.
///
/// Compares only month and day, ignoring the year component.
bool isBirthdayToday(String dateOfBirth) {
  final now = DateTime.now();
  final dob = parseDob(dateOfBirth);
  return now.month == dob.month && now.day == dob.day;
}

/// Formats a [dateOfBirth] string for display (e.g. "15 March 1990").
///
/// Omits the year when the birth year is unknown (`0000`), returning
/// only the day and month (e.g. "15 March").
String formatDate(String dateOfBirth) {
  final dob = parseDob(dateOfBirth);
  final d = DateTime(2000, dob.month, dob.day);
  final dayMonth = DateFormat('d MMMM').format(d);
  if (dob.year == null) return dayMonth;
  return '$dayMonth ${dob.year}';
}

/// Returns the uppercase initials from a [name], up to 2 characters.
///
/// For a single-word name, returns the first letter. For multi-word names,
/// returns the first letter of the first two words. Returns `?` if the
/// name is empty after trimming.
String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
