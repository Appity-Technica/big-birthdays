import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/core/utils.dart';

void main() {
  group('parseDob', () {
    test('parses known year', () {
      final dob = parseDob('1990-03-15');
      expect(dob.year, 1990);
      expect(dob.month, 3);
      expect(dob.day, 15);
    });

    test('parses unknown year as null', () {
      final dob = parseDob('0000-12-25');
      expect(dob.year, isNull);
      expect(dob.month, 12);
      expect(dob.day, 25);
    });
  });

  group('buildDob', () {
    test('builds with known year', () {
      expect(buildDob(2000, 1, 5), '2000-01-05');
    });

    test('builds with unknown year', () {
      expect(buildDob(null, 6, 15), '0000-06-15');
    });

    test('round trip', () {
      final original = '1985-11-03';
      final dob = parseDob(original);
      expect(buildDob(dob.year, dob.month, dob.day), original);
    });
  });

  group('hasKnownYear', () {
    test('returns true for known year', () {
      expect(hasKnownYear('2000-01-01'), isTrue);
    });

    test('returns false for unknown year', () {
      expect(hasKnownYear('0000-05-20'), isFalse);
    });
  });

  group('daysUntilBirthday', () {
    test('returns 0 for today', () {
      final now = DateTime.now();
      final dob = buildDob(1990, now.month, now.day);
      expect(daysUntilBirthday(dob), 0);
    });

    test('returns positive for future date', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 10));
      final dob = buildDob(1990, future.month, future.day);
      expect(daysUntilBirthday(dob), 10);
    });
  });

  group('getCurrentAge', () {
    test('returns null for unknown year', () {
      expect(getCurrentAge('0000-06-15'), isNull);
    });

    test('returns correct age for known year', () {
      final now = DateTime.now();
      // Someone born exactly 30 years ago today
      final dob = buildDob(now.year - 30, now.month, now.day);
      expect(getCurrentAge(dob), 30);
    });
  });

  group('isBirthdayToday', () {
    test('returns true for today', () {
      final now = DateTime.now();
      final dob = buildDob(1990, now.month, now.day);
      expect(isBirthdayToday(dob), isTrue);
    });

    test('returns false for other day', () {
      expect(isBirthdayToday('1990-01-01'),
          DateTime.now().month == 1 && DateTime.now().day == 1);
    });
  });

  group('formatDate', () {
    test('formats with year', () {
      expect(formatDate('2000-03-15'), '15 March 2000');
    });

    test('formats without year', () {
      expect(formatDate('0000-12-25'), '25 December');
    });
  });

  group('getNextBirthday', () {
    test('returns today when birthday is today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dob = buildDob(1990, now.month, now.day);
      final next = getNextBirthday(dob);
      expect(next, today);
    });

    test('returns this year when birthday has not passed', () {
      final now = DateTime.now();
      // Use a date 30 days in the future
      final future = now.add(const Duration(days: 30));
      final dob = buildDob(1990, future.month, future.day);
      final next = getNextBirthday(dob);
      expect(next.year, now.year);
      expect(next.month, future.month);
      expect(next.day, future.day);
    });

    test('returns next year when birthday has passed', () {
      final now = DateTime.now();
      // Use a date 30 days in the past
      final past = now.subtract(const Duration(days: 30));
      final dob = buildDob(1990, past.month, past.day);
      final next = getNextBirthday(dob);
      // Birthday already passed, so it should be next year
      expect(next.year, greaterThanOrEqualTo(now.year));
      expect(next.month, past.month);
      expect(next.day, past.day);
      // Verify it's in the future or today
      final today = DateTime(now.year, now.month, now.day);
      expect(next.isAfter(today) || next.isAtSameMomentAs(today), isTrue);
    });

    test('works with unknown year', () {
      final now = DateTime.now();
      final dob = buildDob(null, now.month, now.day);
      final next = getNextBirthday(dob);
      expect(next.month, now.month);
      expect(next.day, now.day);
    });
  });

  group('getUpcomingAge', () {
    test('returns null for unknown year', () {
      expect(getUpcomingAge('0000-06-15'), isNull);
    });

    test('returns correct upcoming age when birthday is today', () {
      final now = DateTime.now();
      final dob = buildDob(now.year - 25, now.month, now.day);
      expect(getUpcomingAge(dob), 25);
    });

    test('returns correct upcoming age when birthday is in the future', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 30));
      final dob = buildDob(now.year - 30, future.month, future.day);
      expect(getUpcomingAge(dob), 30);
    });

    test('returns next years age when birthday has passed', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 30));
      final dob = buildDob(now.year - 20, past.month, past.day);
      // Birthday passed this year, next birthday is next year
      expect(getUpcomingAge(dob), 21);
    });
  });

  group('getCurrentAge (edge cases)', () {
    test('returns null for unknown year', () {
      expect(getCurrentAge('0000-06-15'), isNull);
    });

    test('returns correct age for known year', () {
      final now = DateTime.now();
      final dob = buildDob(now.year - 30, now.month, now.day);
      expect(getCurrentAge(dob), 30);
    });

    test('subtracts 1 when birthday has not yet occurred this year', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 30));
      final dob = buildDob(now.year - 25, future.month, future.day);
      expect(getCurrentAge(dob), 24);
    });

    test('returns full age when birthday already passed this year', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 30));
      final dob = buildDob(now.year - 25, past.month, past.day);
      expect(getCurrentAge(dob), 25);
    });
  });

  group('getInitials', () {
    test('single name', () {
      expect(getInitials('Alice'), 'A');
    });

    test('two names', () {
      expect(getInitials('John Smith'), 'JS');
    });

    test('multiple names takes first two', () {
      expect(getInitials('Mary Jane Watson'), 'MJ');
    });

    test('handles leading/trailing whitespace', () {
      expect(getInitials('  John Smith  '), 'JS');
    });

    test('handles multiple spaces between names', () {
      expect(getInitials('John    Smith'), 'JS');
    });

    test('lowercased input returns uppercase initials', () {
      expect(getInitials('john smith'), 'JS');
    });
  });
}
