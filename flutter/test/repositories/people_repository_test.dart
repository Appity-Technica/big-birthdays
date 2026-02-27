import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/repositories/people_repository.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // cleanPersonData
  // -------------------------------------------------------------------------
  group('cleanPersonData', () {
    test('adds createdAt and updatedAt with the provided timestamp', () {
      final result = cleanPersonData({'name': 'Alice'}, '2024-01-01T00:00:00Z');

      expect(result['createdAt'], '2024-01-01T00:00:00Z');
      expect(result['updatedAt'], '2024-01-01T00:00:00Z');
    });

    test('preserves existing fields', () {
      final result = cleanPersonData(
        {'name': 'Alice', 'dateOfBirth': '1990-03-15'},
        '2024-01-01T00:00:00Z',
      );

      expect(result['name'], 'Alice');
      expect(result['dateOfBirth'], '1990-03-15');
    });

    test('removes null values', () {
      final result = cleanPersonData(
        {'name': 'Alice', 'photo': null, 'notes': null},
        '2024-01-01T00:00:00Z',
      );

      expect(result.containsKey('photo'), isFalse);
      expect(result.containsKey('notes'), isFalse);
      expect(result['name'], 'Alice');
    });

    test('keeps empty strings (only removes null)', () {
      final result = cleanPersonData(
        {'name': 'Alice', 'notes': ''},
        '2024-01-01T00:00:00Z',
      );

      expect(result['notes'], '');
    });

    test('keeps zero values (only removes null)', () {
      final result = cleanPersonData(
        {'name': 'Alice', 'age': 0},
        '2024-01-01T00:00:00Z',
      );

      expect(result['age'], 0);
    });

    test('overwrites existing createdAt and updatedAt', () {
      final result = cleanPersonData(
        {'name': 'Alice', 'createdAt': 'old', 'updatedAt': 'old'},
        '2024-06-15T12:00:00Z',
      );

      expect(result['createdAt'], '2024-06-15T12:00:00Z');
      expect(result['updatedAt'], '2024-06-15T12:00:00Z');
    });

    test('handles empty data map', () {
      final result = cleanPersonData({}, '2024-01-01T00:00:00Z');

      expect(result.length, 2);
      expect(result['createdAt'], '2024-01-01T00:00:00Z');
      expect(result['updatedAt'], '2024-01-01T00:00:00Z');
    });

    test('does not mutate the original map', () {
      final original = {'name': 'Alice', 'photo': null};
      cleanPersonData(original, '2024-01-01T00:00:00Z');

      // The original should still have the null key.
      expect(original.containsKey('photo'), isTrue);
      expect(original['photo'], isNull);
    });
  });

  // -------------------------------------------------------------------------
  // batchCommitCount
  // -------------------------------------------------------------------------
  group('batchCommitCount', () {
    group('with default batchLimit (500)', () {
      test('returns 0 for 0 items', () {
        expect(batchCommitCount(0), 0);
      });

      test('returns 1 for 1 item', () {
        expect(batchCommitCount(1), 1);
      });

      test('returns 1 for 499 items', () {
        expect(batchCommitCount(499), 1);
      });

      test('returns 1 for exactly 500 items', () {
        expect(batchCommitCount(500), 1);
      });

      test('returns 2 for 501 items', () {
        expect(batchCommitCount(501), 2);
      });

      test('returns 2 for 1000 items', () {
        expect(batchCommitCount(1000), 2);
      });

      test('returns 3 for 1001 items', () {
        expect(batchCommitCount(1001), 3);
      });

      test('returns 3 for 1500 items', () {
        expect(batchCommitCount(1500), 3);
      });

      test('returns 4 for 1501 items', () {
        expect(batchCommitCount(1501), 4);
      });
    });

    group('with custom batchLimit', () {
      test('returns 1 for 5 items with limit 10', () {
        expect(batchCommitCount(5, batchLimit: 10), 1);
      });

      test('returns 1 for 10 items with limit 10', () {
        expect(batchCommitCount(10, batchLimit: 10), 1);
      });

      test('returns 2 for 11 items with limit 10', () {
        expect(batchCommitCount(11, batchLimit: 10), 2);
      });

      test('returns 100 for 1000 items with limit 10', () {
        expect(batchCommitCount(1000, batchLimit: 10), 100);
      });
    });

    group('edge cases', () {
      test('returns 0 for negative item count', () {
        expect(batchCommitCount(-1), 0);
      });

      test('handles very large item counts', () {
        // 10,000 items should need 20 batches of 500.
        expect(batchCommitCount(10000), 20);
      });

      test('handles item count that is one less than a multiple of batch limit', () {
        // 999 items at limit 500 -> 2 batches.
        expect(batchCommitCount(999), 2);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Batch splitting simulation
  // -------------------------------------------------------------------------
  group('batch splitting logic (simulation)', () {
    /// Simulates the batch-splitting loop from [PeopleRepository.batchAddPeople]
    /// and returns the number of batch commits that would be executed.
    int simulateBatchCommits(int itemCount, {int batchLimit = 500}) {
      var count = 0;
      var commits = 0;

      for (var i = 0; i < itemCount; i++) {
        count++;
        if (count % batchLimit == 0) {
          commits++;
        }
      }

      if (count % batchLimit != 0) {
        commits++;
      }

      return commits;
    }

    test('0 items produces 0 commits', () {
      // With 0 items the loop body never runs, and count stays 0,
      // so the trailing commit guard (count % 500 != 0) is false.
      expect(simulateBatchCommits(0), 0);
    });

    test('1 item produces 1 commit', () {
      expect(simulateBatchCommits(1), 1);
    });

    test('499 items produces 1 commit', () {
      expect(simulateBatchCommits(499), 1);
    });

    test('exactly 500 items produces 1 commit (inside loop)', () {
      expect(simulateBatchCommits(500), 1);
    });

    test('501 items produces 2 commits', () {
      expect(simulateBatchCommits(501), 2);
    });

    test('1000 items produces 2 commits', () {
      expect(simulateBatchCommits(1000), 2);
    });

    test('1001 items produces 3 commits', () {
      expect(simulateBatchCommits(1001), 3);
    });

    test('simulation matches batchCommitCount for various sizes', () {
      for (final n in [0, 1, 249, 250, 499, 500, 501, 750, 999, 1000, 1001, 1500, 2500]) {
        expect(
          simulateBatchCommits(n),
          batchCommitCount(n),
          reason: 'mismatch for $n items',
        );
      }
    });

    test('more than 500 items creates multiple batches', () {
      // The task specifically asks to verify that >500 items creates
      // multiple batches.
      expect(simulateBatchCommits(750), greaterThan(1));
      expect(simulateBatchCommits(501), greaterThan(1));
      expect(simulateBatchCommits(1500), greaterThan(1));
    });
  });
}
