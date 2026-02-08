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
  });
}
