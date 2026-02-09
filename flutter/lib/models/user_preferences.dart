class UserPreferences {
  final String country;

  const UserPreferences({
    this.country = 'AU',
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      country: map['country'] as String? ?? 'AU',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'country': country,
    };
  }

  UserPreferences copyWith({String? country}) {
    return UserPreferences(
      country: country ?? this.country,
    );
  }

  static const Map<String, String> supportedCountries = {
    'AU': 'Australia',
    'GB': 'United Kingdom',
    'US': 'United States',
    'CA': 'Canada',
    'IE': 'Ireland',
    'NZ': 'New Zealand',
    'ZA': 'South Africa',
    'IN': 'India',
  };

  String get countryName => supportedCountries[country] ?? country;
}
