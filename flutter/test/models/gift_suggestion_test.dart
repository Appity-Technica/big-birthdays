import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/models/gift_suggestion.dart';

void main() {
  group('GiftSuggestion.fromMap', () {
    test('preserves all fields when fully populated', () {
      final suggestion = GiftSuggestion.fromMap({
        'name': 'Hiking Boots',
        'description': 'Waterproof trail boots',
        'estimatedPrice': '\$120',
        'purchaseUrl': 'https://example.com/boots',
      });

      expect(suggestion.name, 'Hiking Boots');
      expect(suggestion.description, 'Waterproof trail boots');
      expect(suggestion.estimatedPrice, '\$120');
      expect(suggestion.purchaseUrl, 'https://example.com/boots');
    });

    test('defaults to empty strings for missing keys', () {
      final suggestion = GiftSuggestion.fromMap({});

      expect(suggestion.name, '');
      expect(suggestion.description, '');
      expect(suggestion.estimatedPrice, '');
      expect(suggestion.purchaseUrl, '');
    });

    test('defaults to empty strings for null values', () {
      final suggestion = GiftSuggestion.fromMap({
        'name': null,
        'description': null,
        'estimatedPrice': null,
        'purchaseUrl': null,
      });

      expect(suggestion.name, '');
      expect(suggestion.description, '');
      expect(suggestion.estimatedPrice, '');
      expect(suggestion.purchaseUrl, '');
    });

    test('handles partial data', () {
      final suggestion = GiftSuggestion.fromMap({
        'name': 'Book',
        'description': 'A great read',
      });

      expect(suggestion.name, 'Book');
      expect(suggestion.description, 'A great read');
      expect(suggestion.estimatedPrice, '');
      expect(suggestion.purchaseUrl, '');
    });

    test('preserves special characters in fields', () {
      final suggestion = GiftSuggestion.fromMap({
        'name': 'Gift "Deluxe" Edition',
        'description': 'Contains commas, and newlines\nin description',
        'estimatedPrice': '£50–£80',
        'purchaseUrl': 'https://example.com/item?q=a&b=c',
      });

      expect(suggestion.name, 'Gift "Deluxe" Edition');
      expect(suggestion.description, contains('commas'));
      expect(suggestion.estimatedPrice, '£50–£80');
      expect(suggestion.purchaseUrl, contains('?q=a&b=c'));
    });
  });

  group('GiftSuggestion constructor', () {
    test('stores all fields', () {
      const suggestion = GiftSuggestion(
        name: 'Candle',
        description: 'Scented candle',
        estimatedPrice: '\$25',
        purchaseUrl: 'https://example.com',
      );

      expect(suggestion.name, 'Candle');
      expect(suggestion.description, 'Scented candle');
      expect(suggestion.estimatedPrice, '\$25');
      expect(suggestion.purchaseUrl, 'https://example.com');
    });
  });
}
