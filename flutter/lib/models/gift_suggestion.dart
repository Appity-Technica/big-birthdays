/// An AI-generated gift suggestion returned by the Cloud Function.
class GiftSuggestion {
  /// The name or title of the suggested gift.
  final String name;

  /// A short description of why this gift suits the person.
  final String description;

  /// The estimated price as a formatted string (e.g. "$25-$40").
  final String estimatedPrice;

  /// A URL where the gift can be purchased.
  final String purchaseUrl;

  const GiftSuggestion({
    required this.name,
    required this.description,
    required this.estimatedPrice,
    required this.purchaseUrl,
  });

  /// Creates a [GiftSuggestion] from the Cloud Function response map.
  factory GiftSuggestion.fromMap(Map<String, dynamic> map) => GiftSuggestion(
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        estimatedPrice: map['estimatedPrice'] as String? ?? '',
        purchaseUrl: map['purchaseUrl'] as String? ?? '',
      );
}
