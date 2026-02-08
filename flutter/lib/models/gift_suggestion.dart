class GiftSuggestion {
  final String name;
  final String description;
  final String estimatedPrice;
  final String purchaseUrl;

  const GiftSuggestion({
    required this.name,
    required this.description,
    required this.estimatedPrice,
    required this.purchaseUrl,
  });

  factory GiftSuggestion.fromMap(Map<String, dynamic> map) => GiftSuggestion(
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        estimatedPrice: map['estimatedPrice'] as String? ?? '',
        purchaseUrl: map['purchaseUrl'] as String? ?? '',
      );
}
