import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/models/user_preferences.dart';

void main() {
  group('UserPreferences constructor', () {
    test('defaults country to AU', () {
      const prefs = UserPreferences();

      expect(prefs.country, 'AU');
    });

    test('accepts explicit country', () {
      const prefs = UserPreferences(country: 'GB');

      expect(prefs.country, 'GB');
    });
  });

  group('UserPreferences.fromMap', () {
    test('parses country when present', () {
      final prefs = UserPreferences.fromMap({'country': 'US'});

      expect(prefs.country, 'US');
    });

    test('defaults to AU when country key is absent', () {
      final prefs = UserPreferences.fromMap({});

      expect(prefs.country, 'AU');
    });

    test('defaults to AU when country is null', () {
      final prefs = UserPreferences.fromMap({'country': null});

      expect(prefs.country, 'AU');
    });

    test('preserves unknown country code', () {
      final prefs = UserPreferences.fromMap({'country': 'FR'});

      expect(prefs.country, 'FR');
    });
  });

  group('UserPreferences.toMap', () {
    test('serialises country', () {
      const prefs = UserPreferences(country: 'CA');
      final map = prefs.toMap();

      expect(map, {'country': 'CA'});
    });

    test('serialises default country', () {
      const prefs = UserPreferences();
      final map = prefs.toMap();

      expect(map['country'], 'AU');
    });
  });

  group('UserPreferences round-trip', () {
    test('fromMap(toMap()) preserves country', () {
      const original = UserPreferences(country: 'NZ');
      final restored = UserPreferences.fromMap(original.toMap());

      expect(restored.country, original.country);
    });
  });

  group('UserPreferences.copyWith', () {
    test('updates country', () {
      const prefs = UserPreferences(country: 'AU');
      final copy = prefs.copyWith(country: 'IE');

      expect(copy.country, 'IE');
    });

    test('preserves country when not specified', () {
      const prefs = UserPreferences(country: 'ZA');
      final copy = prefs.copyWith();

      expect(copy.country, 'ZA');
    });
  });

  group('UserPreferences.countryName', () {
    test('returns full name for AU', () {
      const prefs = UserPreferences(country: 'AU');
      expect(prefs.countryName, 'Australia');
    });

    test('returns full name for GB', () {
      const prefs = UserPreferences(country: 'GB');
      expect(prefs.countryName, 'United Kingdom');
    });

    test('returns full name for US', () {
      const prefs = UserPreferences(country: 'US');
      expect(prefs.countryName, 'United States');
    });

    test('returns full name for CA', () {
      const prefs = UserPreferences(country: 'CA');
      expect(prefs.countryName, 'Canada');
    });

    test('returns full name for IE', () {
      const prefs = UserPreferences(country: 'IE');
      expect(prefs.countryName, 'Ireland');
    });

    test('returns full name for NZ', () {
      const prefs = UserPreferences(country: 'NZ');
      expect(prefs.countryName, 'New Zealand');
    });

    test('returns full name for ZA', () {
      const prefs = UserPreferences(country: 'ZA');
      expect(prefs.countryName, 'South Africa');
    });

    test('returns full name for IN', () {
      const prefs = UserPreferences(country: 'IN');
      expect(prefs.countryName, 'India');
    });

    test('returns code itself for unknown country', () {
      const prefs = UserPreferences(country: 'FR');
      expect(prefs.countryName, 'FR');
    });

    test('returns code itself for empty string', () {
      const prefs = UserPreferences(country: '');
      expect(prefs.countryName, '');
    });
  });

  group('UserPreferences.supportedCountries', () {
    test('contains exactly 8 entries', () {
      expect(UserPreferences.supportedCountries.length, 8);
    });

    test('contains all expected country codes', () {
      final codes = UserPreferences.supportedCountries.keys.toList();
      expect(codes, containsAll(['AU', 'GB', 'US', 'CA', 'IE', 'NZ', 'ZA', 'IN']));
    });
  });
}
