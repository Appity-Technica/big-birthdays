import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class SocialLink {
  final String platform;
  final String url;
  const SocialLink({required this.platform, required this.url});

  factory SocialLink.fromMap(Map<String, dynamic> map) => SocialLink(
        platform: map['platform'] as String? ?? '',
        url: map['url'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'platform': platform, 'url': url};
}

class PastGift {
  final int year;
  final String description;
  final String? url;
  final int? rating; // 1-5

  const PastGift({
    required this.year,
    required this.description,
    this.url,
    this.rating,
  });

  factory PastGift.fromMap(Map<String, dynamic> map) => PastGift(
        year: (map['year'] as num?)?.toInt() ?? 0,
        description: map['description'] as String? ?? '',
        url: map['url'] as String?,
        rating: (map['rating'] as num?)?.toInt(),
      );

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

class Party {
  final int year;
  final String? date;
  final List<String>? invitedNames;
  final String? notes;

  const Party({
    required this.year,
    this.date,
    this.invitedNames,
    this.notes,
  });

  factory Party.fromMap(Map<String, dynamic> map) => Party(
        year: (map['year'] as num?)?.toInt() ?? 0,
        date: map['date'] as String?,
        invitedNames: (map['invitedNames'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        notes: map['notes'] as String?,
      );

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

class Person {
  final String id;
  final String name;
  final String dateOfBirth;
  final String? photo;
  final Relationship relationship;
  final String? connectedThrough;
  final KnownFrom? knownFrom;
  final String? knownFromCustom;
  final String? notes;
  final List<String>? giftIdeas;
  final List<String>? interests;
  final List<PastGift>? pastGifts;
  final List<Party>? parties;
  final List<SocialLink>? socialLinks;
  final List<NotificationTiming>? notificationTimings;
  final String createdAt;
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
