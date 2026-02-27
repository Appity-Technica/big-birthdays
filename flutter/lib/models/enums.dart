/// The type of relationship between the user and a tracked person.
enum Relationship {
  /// A family member (parent, sibling, cousin, etc.).
  family,

  /// A friend.
  friend,

  /// A work colleague.
  colleague,

  /// Any other relationship not covered above.
  other;

  /// The string value stored in Firestore (matches the enum name).
  String get firestoreValue => name;

  /// Parses a Firestore string into a [Relationship].
  ///
  /// Returns [Relationship.other] for `null` or unrecognised values.
  static Relationship fromFirestore(String? value) {
    if (value == null) return Relationship.other;
    return Relationship.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Relationship.other,
    );
  }

  /// Human-readable label for display in the UI.
  String get displayLabel {
    switch (this) {
      case Relationship.family:
        return 'Family';
      case Relationship.friend:
        return 'Friend';
      case Relationship.colleague:
        return 'Colleague';
      case Relationship.other:
        return 'Other';
    }
  }
}

/// How the user originally met or knows a tracked person.
enum KnownFrom {
  /// Met through school.
  school,

  /// Met through dance classes or groups.
  dance,

  /// Met through sports.
  sports,

  /// Met through scouts or guides.
  scouts,

  /// A neighbour.
  neighbourhood,

  /// Met through work.
  work,

  /// Met through church or religious community.
  church,

  /// A friend of the family.
  familyFriend,

  /// Any other context not covered above.
  other;

  /// The string value stored in Firestore.
  ///
  /// [familyFriend] is stored as `'family-friend'`; all others use the enum name.
  String get firestoreValue {
    if (this == KnownFrom.familyFriend) return 'family-friend';
    return name;
  }

  /// Parses a Firestore string into a [KnownFrom].
  ///
  /// Returns `null` for `null` input, and [KnownFrom.other] for
  /// unrecognised values.
  static KnownFrom? fromFirestore(String? value) {
    if (value == null) return null;
    if (value == 'family-friend') return KnownFrom.familyFriend;
    return KnownFrom.values.firstWhere(
      (e) => e.name == value,
      orElse: () => KnownFrom.other,
    );
  }

  /// Human-readable label for display in the UI.
  String get displayLabel {
    switch (this) {
      case KnownFrom.familyFriend:
        return 'Family friend';
      case KnownFrom.neighbourhood:
        return 'Neighbourhood';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

/// How far in advance to send a birthday reminder notification.
enum NotificationTiming {
  /// Notify on the birthday itself.
  onTheDay,

  /// Notify 1 day before the birthday.
  oneDay,

  /// Notify 3 days before the birthday.
  threeDays,

  /// Notify 1 week before the birthday.
  oneWeek,

  /// Notify 2 weeks before the birthday.
  twoWeeks;

  /// The string value stored in Firestore (e.g. `'on-the-day'`, `'1-day'`).
  String get firestoreValue {
    switch (this) {
      case NotificationTiming.onTheDay:
        return 'on-the-day';
      case NotificationTiming.oneDay:
        return '1-day';
      case NotificationTiming.threeDays:
        return '3-days';
      case NotificationTiming.oneWeek:
        return '1-week';
      case NotificationTiming.twoWeeks:
        return '2-weeks';
    }
  }

  /// Parses a Firestore string into a [NotificationTiming].
  ///
  /// Defaults to [NotificationTiming.onTheDay] for unrecognised values.
  static NotificationTiming fromFirestore(String value) {
    switch (value) {
      case 'on-the-day':
        return NotificationTiming.onTheDay;
      case '1-day':
        return NotificationTiming.oneDay;
      case '3-days':
        return NotificationTiming.threeDays;
      case '1-week':
        return NotificationTiming.oneWeek;
      case '2-weeks':
        return NotificationTiming.twoWeeks;
      default:
        return NotificationTiming.onTheDay;
    }
  }

  /// Human-readable label for display in the UI.
  String get displayLabel {
    switch (this) {
      case NotificationTiming.onTheDay:
        return 'On the day';
      case NotificationTiming.oneDay:
        return '1 day before';
      case NotificationTiming.threeDays:
        return '3 days before';
      case NotificationTiming.oneWeek:
        return '1 week before';
      case NotificationTiming.twoWeeks:
        return '2 weeks before';
    }
  }
}
