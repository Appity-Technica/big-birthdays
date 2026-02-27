import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// A link to one of a person's social media profiles.
class SocialLink {
  /// The platform name (e.g. "instagram", "facebook").
  final String platform;

  /// The full URL to the profile.
  final String url;
  const SocialLink({required this.platform, required this.url});

  /// Creates a [SocialLink] from a Firestore map.
  factory SocialLink.fromMap(Map<String, dynamic> map) => SocialLink(
        platform: map['platform'] as String? ?? '',
        url: map['url'] as String? ?? '',
      );

  /// Converts this link to a Firestore-compatible map.
  Map<String, dynamic> toMap() => {'platform': platform, 'url': url};
}

/// A gift that was given to a person in a previous year.
class PastGift {
  /// The year the gift was given.
  final int year;

  /// A description of the gift.
  final String description;

  /// Optional URL (e.g. a product link).
  final String? url;

  /// Optional rating from 1 (poor) to 5 (loved it).
  final int? rating; // 1-5

  const PastGift({
    required this.year,
    required this.description,
    this.url,
    this.rating,
  });

  /// Creates a [PastGift] from a Firestore map.
  factory PastGift.fromMap(Map<String, dynamic> map) => PastGift(
        year: (map['year'] as num?)?.toInt() ?? 0,
        description: map['description'] as String? ?? '',
        url: map['url'] as String?,
        rating: (map['rating'] as num?)?.toInt(),
      );

  /// Converts to a Firestore-compatible map, omitting empty optional fields.
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'year': year,
      'description': description,
    };
    if (url != null && url!.isNotEmpty) m['url'] = url;
    if (rating != null && rating! > 0) m['rating'] = rating;
    return m;
  }
}

/// A birthday party record for a given year.
class Party {
  /// The year the party took place or is planned.
  final int year;

  /// Optional date string for the party.
  final String? date;

  /// Optional list of invited guest names.
  final List<String>? invitedNames;

  /// Optional notes about the party.
  final String? notes;

  const Party({
    required this.year,
    this.date,
    this.invitedNames,
    this.notes,
  });

  /// Creates a [Party] from a Firestore map.
  factory Party.fromMap(Map<String, dynamic> map) => Party(
        year: (map['year'] as num?)?.toInt() ?? 0,
        date: map['date'] as String?,
        invitedNames: (map['invitedNames'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        notes: map['notes'] as String?,
      );

  /// Converts to a Firestore-compatible map, omitting empty optional fields.
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{'year': year};
    if (date != null && date!.isNotEmpty) m['date'] = date;
    if (invitedNames != null && invitedNames!.isNotEmpty) {
      m['invitedNames'] = invitedNames;
    }
    if (notes != null && notes!.isNotEmpty) m['notes'] = notes;
    return m;
  }
}

/// A person whose birthday is being tracked.
///
/// Stored in Firestore under `users/{userId}/people/{personId}`.
/// The [dateOfBirth] is in `YYYY-MM-DD` format, where a year of `0000`
/// indicates the birth year is unknown.
class Person {
  /// Firestore document ID.
  final String id;

  /// The person's display name.
  final String name;

  /// Date of birth in `YYYY-MM-DD` format. Year `0000` means unknown.
  final String dateOfBirth;

  /// Optional base64-encoded photo or URL.
  final String? photo;

  /// How this person is related to the user.
  final Relationship relationship;

  /// Optional name of someone the user knows this person through.
  final String? connectedThrough;

  /// How the user originally met this person.
  final KnownFrom? knownFrom;

  /// Custom description when [knownFrom] is [KnownFrom.other].
  final String? knownFromCustom;

  /// Free-text notes about this person.
  final String? notes;

  /// User-entered gift ideas for future reference.
  final List<String>? giftIdeas;

  /// The person's interests/hobbies, used for AI gift suggestions.
  final List<String>? interests;

  /// History of gifts given to this person.
  final List<PastGift>? pastGifts;

  /// Party records for this person.
  final List<Party>? parties;

  /// Links to the person's social media profiles.
  final List<SocialLink>? socialLinks;

  /// When to send birthday reminder notifications.
  final List<NotificationTiming>? notificationTimings;

  /// ISO 8601 timestamp when this record was created.
  final String createdAt;

  /// ISO 8601 timestamp when this record was last updated.
  final String updatedAt;

  const Person({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.photo,
    required this.relationship,
    this.connectedThrough,
    this.knownFrom,
    this.knownFromCustom,
    this.notes,
    this.giftIdeas,
    this.interests,
    this.pastGifts,
    this.parties,
    this.socialLinks,
    this.notificationTimings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Person] from a Firestore document snapshot.
  ///
  /// Defaults [dateOfBirth] to `'0000-01-01'` and [relationship] to
  /// [Relationship.other] when the corresponding fields are missing.
  factory Person.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Person(
      id: doc.id,
      name: data['name'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] as String? ?? '0000-01-01',
      photo: data['photo'] as String?,
      relationship: Relationship.fromFirestore(data['relationship'] as String?),
      connectedThrough: data['connectedThrough'] as String?,
      knownFrom: KnownFrom.fromFirestore(data['knownFrom'] as String?),
      knownFromCustom: data['knownFromCustom'] as String?,
      notes: data['notes'] as String?,
      giftIdeas: (data['giftIdeas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      interests: (data['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pastGifts: (data['pastGifts'] as List<dynamic>?)
          ?.map((e) => PastGift.fromMap(e as Map<String, dynamic>))
          .toList(),
      parties: (data['parties'] as List<dynamic>?)
          ?.map((e) => Party.fromMap(e as Map<String, dynamic>))
          .toList(),
      socialLinks: (data['socialLinks'] as List<dynamic>?)
          ?.map((e) => SocialLink.fromMap(e as Map<String, dynamic>))
          .toList(),
      notificationTimings: (data['notificationTimings'] as List<dynamic>?)
          ?.map((e) => NotificationTiming.fromFirestore(e as String))
          .toList(),
      createdAt: data['createdAt'] as String? ?? '',
      updatedAt: data['updatedAt'] as String? ?? '',
    );
  }

  /// Converts this person to a Firestore-compatible map.
  ///
  /// Only includes optional fields when they are non-null and non-empty.
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'name': name,
      'dateOfBirth': dateOfBirth,
      'relationship': relationship.firestoreValue,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
    if (photo != null) map['photo'] = photo;
    if (connectedThrough != null && connectedThrough!.isNotEmpty) {
      map['connectedThrough'] = connectedThrough;
    }
    if (knownFrom != null) map['knownFrom'] = knownFrom!.firestoreValue;
    if (knownFromCustom != null && knownFromCustom!.isNotEmpty) {
      map['knownFromCustom'] = knownFromCustom;
    }
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    if (giftIdeas != null && giftIdeas!.isNotEmpty) {
      map['giftIdeas'] = giftIdeas;
    }
    if (interests != null && interests!.isNotEmpty) {
      map['interests'] = interests;
    }
    if (pastGifts != null && pastGifts!.isNotEmpty) {
      map['pastGifts'] = pastGifts!.map((g) => g.toMap()).toList();
    }
    if (parties != null && parties!.isNotEmpty) {
      map['parties'] = parties!.map((p) => p.toMap()).toList();
    }
    if (socialLinks != null && socialLinks!.isNotEmpty) {
      map['socialLinks'] = socialLinks!.map((s) => s.toMap()).toList();
    }
    if (notificationTimings != null && notificationTimings!.isNotEmpty) {
      map['notificationTimings'] =
          notificationTimings!.map((t) => t.firestoreValue).toList();
    }
    return map;
  }

  /// Returns a copy of this person with the given fields replaced.
  Person copyWith({
    String? name,
    String? dateOfBirth,
    String? photo,
    Relationship? relationship,
    String? connectedThrough,
    KnownFrom? knownFrom,
    String? knownFromCustom,
    String? notes,
    List<String>? giftIdeas,
    List<String>? interests,
    List<PastGift>? pastGifts,
    List<Party>? parties,
    List<SocialLink>? socialLinks,
    List<NotificationTiming>? notificationTimings,
    String? updatedAt,
  }) {
    return Person(
      id: id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photo: photo ?? this.photo,
      relationship: relationship ?? this.relationship,
      connectedThrough: connectedThrough ?? this.connectedThrough,
      knownFrom: knownFrom ?? this.knownFrom,
      knownFromCustom: knownFromCustom ?? this.knownFromCustom,
      notes: notes ?? this.notes,
      giftIdeas: giftIdeas ?? this.giftIdeas,
      interests: interests ?? this.interests,
      pastGifts: pastGifts ?? this.pastGifts,
      parties: parties ?? this.parties,
      socialLinks: socialLinks ?? this.socialLinks,
      notificationTimings: notificationTimings ?? this.notificationTimings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
