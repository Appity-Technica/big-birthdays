import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/core/constants.dart';

void main() {
  group('AppColors.accentForIndex', () {
    test('index 0 returns pink', () {
      expect(AppColors.accentForIndex(0), AppColors.pink);
    });

    test('index 1 returns teal', () {
      expect(AppColors.accentForIndex(1), AppColors.teal);
    });

    test('index 2 returns orange', () {
      expect(AppColors.accentForIndex(2), AppColors.orange);
    });

    test('index 3 returns coral', () {
      expect(AppColors.accentForIndex(3), AppColors.coral);
    });

    test('index 4 returns purpleLight', () {
      expect(AppColors.accentForIndex(4), AppColors.purpleLight);
    });

    test('wraps around at index 5', () {
      expect(AppColors.accentForIndex(5), AppColors.pink);
    });

    test('wraps around at index 6', () {
      expect(AppColors.accentForIndex(6), AppColors.teal);
    });

    test('handles large index', () {
      expect(AppColors.accentForIndex(100), AppColors.accentForIndex(0));
    });

    test('handles negative index via Dart modulo', () {
      // Dart's % operator with negative LHS returns negative result,
      // but since name.hashCode can be negative, this tests that path.
      // The result depends on Dart's modulo behavior.
      final color = AppColors.accentForIndex(-1);
      expect(AppColors.accentColors.contains(color), isTrue);
    });
  });

  group('AppColors.accentColors', () {
    test('contains exactly 5 colors', () {
      expect(AppColors.accentColors.length, 5);
    });

    test('all colors are distinct', () {
      final unique = AppColors.accentColors.toSet();
      expect(unique.length, AppColors.accentColors.length);
    });
  });
}
