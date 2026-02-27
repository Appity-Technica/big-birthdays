import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/repositories/export_repository.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/models/enums.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Person _testPerson({
  String name = 'Test Person',
  String dateOfBirth = '2000-06-15',
  Relationship relationship = Relationship.friend,
  String? connectedThrough,
  KnownFrom? knownFrom,
  String? notes,
  List<String>? interests,
  List<String>? giftIdeas,
}) {
  return Person(
    id: 'test-id',
    name: name,
    dateOfBirth: dateOfBirth,
    relationship: relationship,
    connectedThrough: connectedThrough,
    knownFrom: knownFrom,
    notes: notes,
    interests: interests,
    giftIdeas: giftIdeas,
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late ExportRepository repo;

  setUp(() {
    repo = ExportRepository();
  });

  // -------------------------------------------------------------------------
  // generateCsv
  // -------------------------------------------------------------------------
  group('generateCsv', () {
    test('with empty list returns only the header row', () {
      final csv = repo.generateCsv([]);
      final lines = csv.trim().split('\n');

      expect(lines.length, 1);
      expect(lines[0],
          'Name,Date of Birth,Relationship,Connected Through,Known From,Notes,Interests,Gift Ideas');
    });

    test('header has correct column order', () {
      final csv = repo.generateCsv([]);
      final header = csv.trim().split('\n').first;
      final columns = header.split(',');

      expect(columns[0], 'Name');
      expect(columns[1], 'Date of Birth');
      expect(columns[2], 'Relationship');
      expect(columns[3], 'Connected Through');
      expect(columns[4], 'Known From');
      expect(columns[5], 'Notes');
      expect(columns[6], 'Interests');
      expect(columns[7], 'Gift Ideas');
    });

    test('with a single minimal person produces header + one data row', () {
      final csv = repo.generateCsv([_testPerson()]);
      final lines = csv.trim().split('\n');

      expect(lines.length, 2);
    });

    test('data row contains name and date of birth', () {
      final csv = repo.generateCsv([_testPerson(name: 'Alice', dateOfBirth: '1990-03-15')]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Alice'));
      expect(dataRow, contains('1990-03-15'));
    });

    test('data row contains relationship display label', () {
      final csv = repo.generateCsv([_testPerson(relationship: Relationship.family)]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Family'));
    });

    test('data row contains knownFrom display label', () {
      final csv = repo.generateCsv([_testPerson(knownFrom: KnownFrom.school)]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('School'));
    });

    test('data row contains connectedThrough value', () {
      final csv = repo.generateCsv([_testPerson(connectedThrough: 'Bob')]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Bob'));
    });

    test('data row contains notes', () {
      final csv = repo.generateCsv([_testPerson(notes: 'Loves jazz')]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Loves jazz'));
    });

    test('interests are joined with semicolons', () {
      final csv = repo.generateCsv([
        _testPerson(interests: ['Hiking', 'Photography']),
      ]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Hiking; Photography'));
    });

    test('giftIdeas are joined with semicolons', () {
      final csv = repo.generateCsv([
        _testPerson(giftIdeas: ['Book', 'Candle']),
      ]);
      final dataRow = csv.trim().split('\n')[1];

      expect(dataRow, contains('Book; Candle'));
    });

    test('multiple people produce one row each', () {
      final people = [
        _testPerson(name: 'Alice'),
        _testPerson(name: 'Bob'),
        _testPerson(name: 'Charlie'),
      ];
      final csv = repo.generateCsv(people);
      // trim to remove trailing newline before counting
      final lines = csv.trim().split('\n');

      // 1 header + 3 data rows
      expect(lines.length, 4);
    });

    group('CSV escaping', () {
      test('name containing a comma is wrapped in double quotes', () {
        final csv = repo.generateCsv([_testPerson(name: 'Smith, John')]);
        final dataRow = csv.trim().split('\n')[1];

        expect(dataRow, startsWith('"Smith, John"'));
      });

      test('name containing double quotes escapes them', () {
        final csv = repo.generateCsv([_testPerson(name: 'Bob "The Builder"')]);
        final dataRow = csv.trim().split('\n')[1];

        // RFC 4180: double quotes are escaped by doubling them
        expect(dataRow, contains('"Bob ""The Builder"""'));
      });

      test('field with newline is wrapped in double quotes', () {
        final csv = repo.generateCsv([_testPerson(notes: 'Line one\nLine two')]);
        expect(csv, contains('"Line one\nLine two"'));
      });

      test('plain field without special chars is not quoted', () {
        final csv = repo.generateCsv([_testPerson(name: 'Alice')]);
        final dataRow = csv.trim().split('\n')[1];

        // Plain name should not be wrapped in quotes
        expect(dataRow, startsWith('Alice,'));
      });
    });
  });

  // -------------------------------------------------------------------------
  // generatePersonSummary
  // -------------------------------------------------------------------------
  group('generatePersonSummary', () {
    test('always includes name on first line', () {
      final summary = repo.generatePersonSummary(_testPerson(name: 'Alice'));
      final firstLine = summary.split('\n').first;

      expect(firstLine, 'Alice');
    });

    test('always includes birthday line', () {
      final summary = repo.generatePersonSummary(_testPerson(dateOfBirth: '1990-03-15'));

      expect(summary, contains('Birthday: 1990-03-15'));
    });

    test('always includes relationship line with display label', () {
      final summary = repo.generatePersonSummary(_testPerson(relationship: Relationship.colleague));

      expect(summary, contains('Relationship: Colleague'));
    });

    test('includes connectedThrough when set', () {
      final summary = repo.generatePersonSummary(_testPerson(connectedThrough: 'Dave'));

      expect(summary, contains('Connected through: Dave'));
    });

    test('omits connectedThrough when null', () {
      final summary = repo.generatePersonSummary(_testPerson());

      expect(summary, isNot(contains('Connected through')));
    });

    test('omits connectedThrough when empty string', () {
      final summary = repo.generatePersonSummary(_testPerson(connectedThrough: ''));

      expect(summary, isNot(contains('Connected through')));
    });

    test('includes interests joined with commas when set', () {
      final summary = repo.generatePersonSummary(
        _testPerson(interests: ['Hiking', 'Photography']),
      );

      expect(summary, contains('Interests: Hiking, Photography'));
    });

    test('omits interests when null', () {
      final summary = repo.generatePersonSummary(_testPerson());

      expect(summary, isNot(contains('Interests')));
    });

    test('omits interests when empty list', () {
      final summary = repo.generatePersonSummary(_testPerson(interests: []));

      expect(summary, isNot(contains('Interests')));
    });

    test('includes giftIdeas joined with commas when set', () {
      final summary = repo.generatePersonSummary(
        _testPerson(giftIdeas: ['Book', 'Candle']),
      );

      expect(summary, contains('Gift ideas: Book, Candle'));
    });

    test('omits giftIdeas when null', () {
      final summary = repo.generatePersonSummary(_testPerson());

      expect(summary, isNot(contains('Gift ideas')));
    });

    test('omits giftIdeas when empty list', () {
      final summary = repo.generatePersonSummary(_testPerson(giftIdeas: []));

      expect(summary, isNot(contains('Gift ideas')));
    });

    test('lines are separated by newlines', () {
      final summary = repo.generatePersonSummary(
        _testPerson(name: 'Alice', connectedThrough: 'Bob'),
      );

      expect(summary, contains('\n'));
    });

    test('fully-populated person includes all optional sections', () {
      final summary = repo.generatePersonSummary(
        _testPerson(
          name: 'Alice',
          dateOfBirth: '1990-03-15',
          relationship: Relationship.friend,
          connectedThrough: 'Bob',
          interests: ['Jazz', 'Cooking'],
          giftIdeas: ['Vinyl record'],
        ),
      );

      expect(summary, contains('Alice'));
      expect(summary, contains('Birthday: 1990-03-15'));
      expect(summary, contains('Relationship: Friend'));
      expect(summary, contains('Connected through: Bob'));
      expect(summary, contains('Interests: Jazz, Cooking'));
      expect(summary, contains('Gift ideas: Vinyl record'));
    });

    test('minimal person summary has exactly three lines', () {
      final summary = repo.generatePersonSummary(_testPerson());
      final lines = summary.split('\n');

      // name, birthday, relationship — nothing else
      expect(lines.length, 3);
    });
  });
}
