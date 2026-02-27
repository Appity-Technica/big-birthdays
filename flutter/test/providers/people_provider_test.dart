import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:big_birthdays/models/enums.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/providers/people_provider.dart';

/// Helper to build a date-of-birth string for a given month and day in the
/// format YYYY-MM-DD. The year defaults to 1990 so that [hasKnownYear] is true.
String _dob(int month, int day, {int year = 1990}) {
  final y = year.toString().padLeft(4, '0');
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Returns today's month and day as (month, day).
(int, int) _today() {
  final now = DateTime.now();
  return (now.month, now.day);
}

/// Returns a future date that is [daysAhead] days from today as (month, day).
/// Handles month/year rollover via DateTime arithmetic.
(int, int) _futureDate(int daysAhead) {
  final future = DateTime.now().add(Duration(days: daysAhead));
  return (future.month, future.day);
}

Person _makePerson({
  required String id,
  required String name,
  required String dateOfBirth,
  Relationship relationship = Relationship.friend,
}) {
  return Person(
    id: id,
    name: name,
    dateOfBirth: dateOfBirth,
    relationship: relationship,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );
}

/// Creates a [ProviderContainer] with [peopleStreamProvider] overridden
/// to return the given [people] as a resolved [AsyncValue.data].
ProviderContainer _createContainer(List<Person> people) {
  return ProviderContainer(
    overrides: [
      peopleStreamProvider.overrideWithValue(AsyncValue.data(people)),
    ],
  );
}

void main() {
  group('todayBirthdaysProvider', () {
    test('returns people whose birthday is today', () {
      final (todayMonth, todayDay) = _today();
      final (futureMonth, futureDay) = _futureDate(30);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Alice',
          dateOfBirth: _dob(todayMonth, todayDay),
        ),
        _makePerson(
          id: '2',
          name: 'Bob',
          dateOfBirth: _dob(futureMonth, futureDay),
        ),
        _makePerson(
          id: '3',
          name: 'Charlie',
          dateOfBirth: _dob(todayMonth, todayDay, year: 2000),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final todayBirthdays = container.read(todayBirthdaysProvider);

      expect(todayBirthdays, hasLength(2));
      expect(
        todayBirthdays.map((p) => p.name),
        containsAll(['Alice', 'Charlie']),
      );
      expect(todayBirthdays.map((p) => p.name), isNot(contains('Bob')));
    });

    test('returns empty list when no birthdays are today', () {
      final (futureMonth, futureDay) = _futureDate(10);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Alice',
          dateOfBirth: _dob(futureMonth, futureDay),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final todayBirthdays = container.read(todayBirthdaysProvider);
      expect(todayBirthdays, isEmpty);
    });

    test('returns empty list when people list is empty', () {
      final container = _createContainer([]);
      addTearDown(container.dispose);

      final todayBirthdays = container.read(todayBirthdaysProvider);
      expect(todayBirthdays, isEmpty);
    });
  });

  group('upcomingBirthdaysProvider', () {
    test('excludes people whose birthday is today', () {
      final (todayMonth, todayDay) = _today();
      final (futureMonth, futureDay) = _futureDate(15);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Alice',
          dateOfBirth: _dob(todayMonth, todayDay),
        ),
        _makePerson(
          id: '2',
          name: 'Bob',
          dateOfBirth: _dob(futureMonth, futureDay),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final upcoming = container.read(upcomingBirthdaysProvider);

      expect(upcoming, hasLength(1));
      expect(upcoming.first.name, 'Bob');
    });

    test('sorts by days until next birthday in ascending order', () {
      final (m5, d5) = _futureDate(5);
      final (m20, d20) = _futureDate(20);
      final (m60, d60) = _futureDate(60);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Far',
          dateOfBirth: _dob(m60, d60),
        ),
        _makePerson(
          id: '2',
          name: 'Near',
          dateOfBirth: _dob(m5, d5),
        ),
        _makePerson(
          id: '3',
          name: 'Middle',
          dateOfBirth: _dob(m20, d20),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final upcoming = container.read(upcomingBirthdaysProvider);

      expect(upcoming, hasLength(3));
      expect(upcoming[0].name, 'Near');
      expect(upcoming[1].name, 'Middle');
      expect(upcoming[2].name, 'Far');
    });

    test('returns empty list when all birthdays are today', () {
      final (todayMonth, todayDay) = _today();

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Alice',
          dateOfBirth: _dob(todayMonth, todayDay),
        ),
        _makePerson(
          id: '2',
          name: 'Bob',
          dateOfBirth: _dob(todayMonth, todayDay, year: 1985),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final upcoming = container.read(upcomingBirthdaysProvider);
      expect(upcoming, isEmpty);
    });

    test('returns empty list when no people exist', () {
      final container = _createContainer([]);
      addTearDown(container.dispose);

      final upcoming = container.read(upcomingBirthdaysProvider);
      expect(upcoming, isEmpty);
    });
  });

  group('personByIdProvider', () {
    test('returns the correct person for a valid ID', () {
      final (m1, d1) = _futureDate(10);
      final (m2, d2) = _futureDate(20);

      final mockPeople = [
        _makePerson(
          id: 'abc123',
          name: 'Alice',
          dateOfBirth: _dob(m1, d1),
        ),
        _makePerson(
          id: 'def456',
          name: 'Bob',
          dateOfBirth: _dob(m2, d2),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final alice = container.read(personByIdProvider('abc123'));
      expect(alice, isNotNull);
      expect(alice!.name, 'Alice');
      expect(alice.id, 'abc123');

      final bob = container.read(personByIdProvider('def456'));
      expect(bob, isNotNull);
      expect(bob!.name, 'Bob');
    });

    test('returns null for a non-existent ID', () {
      final (m1, d1) = _futureDate(10);

      final mockPeople = [
        _makePerson(
          id: 'abc123',
          name: 'Alice',
          dateOfBirth: _dob(m1, d1),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final result = container.read(personByIdProvider('nonexistent'));
      expect(result, isNull);
    });

    test('returns null when people list is empty', () {
      final container = _createContainer([]);
      addTearDown(container.dispose);

      final result = container.read(personByIdProvider('anyid'));
      expect(result, isNull);
    });
  });

  group('todayBirthdaysProvider and upcomingBirthdaysProvider integration', () {
    test('together they account for all people', () {
      final (todayMonth, todayDay) = _today();
      final (futureMonth, futureDay) = _futureDate(30);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Birthday Today',
          dateOfBirth: _dob(todayMonth, todayDay),
        ),
        _makePerson(
          id: '2',
          name: 'Birthday Later',
          dateOfBirth: _dob(futureMonth, futureDay),
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final today = container.read(todayBirthdaysProvider);
      final upcoming = container.read(upcomingBirthdaysProvider);

      // Together they should cover all people with no overlap.
      expect(today.length + upcoming.length, mockPeople.length);

      final allIds = {...today.map((p) => p.id), ...upcoming.map((p) => p.id)};
      expect(allIds, hasLength(mockPeople.length));
    });
  });

  group('upcomingBirthdaysProvider with unknown year', () {
    test('handles people with unknown birth year (0000)', () {
      final (m1, d1) = _futureDate(10);

      final mockPeople = [
        _makePerson(
          id: '1',
          name: 'Unknown Year',
          dateOfBirth: _dob(m1, d1, year: 0), // 0000-MM-DD
        ),
      ];

      final container = _createContainer(mockPeople);
      addTearDown(container.dispose);

      final upcoming = container.read(upcomingBirthdaysProvider);
      expect(upcoming, hasLength(1));
      expect(upcoming.first.name, 'Unknown Year');
    });
  });
}
