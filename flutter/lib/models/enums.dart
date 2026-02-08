enum Relationship {
  family,
  friend,
  colleague,
  other;

  String get firestoreValue => name;

  static Relationship fromFirestore(String? value) {
    if (value == null) return Relationship.other;
    return Relationship.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Relationship.other,
    );
  }

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

enum KnownFrom {
  school,
  dance,
  sports,
  scouts,
  neighbourhood,
  work,
  church,
  familyFriend,
  other;

  String get firestoreValue {
    if (this == KnownFrom.familyFriend) return 'family-friend';
    return name;
  }

  static KnownFrom? fromFirestore(String? value) {
    if (value == null) return null;
    if (value == 'family-friend') return KnownFrom.familyFriend;
    return KnownFrom.values.firstWhere(
      (e) => e.name == value,
      orElse: () => KnownFrom.other,
    );
  }

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

enum NotificationTiming {
  onTheDay,
  oneDay,
  threeDays,
  oneWeek,
  twoWeeks;

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
