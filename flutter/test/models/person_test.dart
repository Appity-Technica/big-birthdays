import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/models/enums.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Person _minimalPerson() => const Person(
      id: 'person-1',
      name: 'Alice',
      dateOfBirth: '1990-03-15',
      relationship: Relationship.friend,
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
    );

Person _fullPerson() => Person(
      id: 'person-2',
      name: 'Bob Smith',
      dateOfBirth: '1985-11-03',
      photo: 'https://example.com/photo.jpg',
      relationship: Relationship.family,
      connectedThrough: 'Alice',
      knownFrom: KnownFrom.school,
      knownFromCustom: 'Primary school',
      notes: 'Loves hiking',
      giftIdeas: ['Book', 'Hiking boots'],
      interests: ['Hiking', 'Photography'],
      pastGifts: [
        const PastGift(year: 2023, description: 'Book', url: 'https://example.com/book', rating: 4),
        const PastGift(year: 2022, description: 'Scarf'),
      ],
      parties: [
        Party(year: 2023, date: '2023-11-03', invitedNames: ['Alice', 'Charlie'], notes: 'Surprise party'),
        const Party(year: 2022),
      ],
      socialLinks: [
        const SocialLink(platform: 'instagram', url: 'https://instagram.com/bob'),
      ],
      notificationTimings: [NotificationTiming.oneWeek, NotificationTiming.onTheDay],
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-06-01T00:00:00Z',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // SocialLink
  // -------------------------------------------------------------------------
  group('SocialLink', () {
    group('toMap / fromMap round-trip', () {
      test('preserves platform and url', () {
        const link = SocialLink(platform: 'twitter', url: 'https://twitter.com/alice');
        final map = link.toMap();
        final restored = SocialLink.fromMap(map);

        expect(restored.platform, link.platform);
        expect(restored.url, link.url);
      });

      test('toMap contains expected keys', () {
        const link = SocialLink(platform: 'instagram', url: 'https://instagram.com/bob');
        final map = link.toMap();

        expect(map['platform'], 'instagram');
        expect(map['url'], 'https://instagram.com/bob');
        expect(map.length, 2);
      });

      test('fromMap defaults to empty strings for missing keys', () {
        final link = SocialLink.fromMap({});

        expect(link.platform, '');
        expect(link.url, '');
      });
    });
  });

  // -------------------------------------------------------------------------
  // PastGift
  // -------------------------------------------------------------------------
  group('PastGift', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields when fully populated', () {
        const gift = PastGift(year: 2023, description: 'Hiking boots', url: 'https://example.com', rating: 5);
        final map = gift.toMap();
        final restored = PastGift.fromMap(map);

        expect(restored.year, gift.year);
        expect(restored.description, gift.description);
        expect(restored.url, gift.url);
        expect(restored.rating, gift.rating);
      });

      test('omits null url from map', () {
        const gift = PastGift(year: 2022, description: 'Scarf');
        final map = gift.toMap();

        expect(map.containsKey('url'), isFalse);
      });

      test('omits null rating from map', () {
        const gift = PastGift(year: 2022, description: 'Scarf');
        final map = gift.toMap();

        expect(map.containsKey('rating'), isFalse);
      });

      test('omits zero rating from map', () {
        const gift = PastGift(year: 2022, description: 'Mug', rating: 0);
        final map = gift.toMap();

        expect(map.containsKey('rating'), isFalse);
      });

      test('fromMap with missing optional fields sets them to null', () {
        final gift = PastGift.fromMap({'year': 2021, 'description': 'Hat'});

        expect(gift.url, isNull);
        expect(gift.rating, isNull);
      });

      test('fromMap defaults year to 0 when absent', () {
        final gift = PastGift.fromMap({'description': 'Gloves'});

        expect(gift.year, 0);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Party
  // -------------------------------------------------------------------------
  group('Party', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields when fully populated', () {
        final party = Party(
          year: 2023,
          date: '2023-11-03',
          invitedNames: ['Alice', 'Bob'],
          notes: 'Surprise',
        );
        final map = party.toMap();
        final restored = Party.fromMap(map);

        expect(restored.year, party.year);
        expect(restored.date, party.date);
        expect(restored.invitedNames, party.invitedNames);
        expect(restored.notes, party.notes);
      });

      test('omits null date from map', () {
        const party = Party(year: 2022);
        final map = party.toMap();

        expect(map.containsKey('date'), isFalse);
      });

      test('omits empty invitedNames from map', () {
        final party = Party(year: 2022, invitedNames: []);
        final map = party.toMap();

        expect(map.containsKey('invitedNames'), isFalse);
      });

      test('omits null notes from map', () {
        const party = Party(year: 2022);
        final map = party.toMap();

        expect(map.containsKey('notes'), isFalse);
      });

      test('fromMap with only year sets optionals to null', () {
        final party = Party.fromMap({'year': 2020});

        expect(party.date, isNull);
        expect(party.invitedNames, isNull);
        expect(party.notes, isNull);
      });

      test('fromMap preserves invitedNames list', () {
        final party = Party.fromMap({
          'year': 2023,
          'invitedNames': ['Charlie', 'Diana'],
        });

        expect(party.invitedNames, ['Charlie', 'Diana']);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Person.toFirestore()
  // -------------------------------------------------------------------------
  group('Person.toFirestore()', () {
    group('minimal person', () {
      late Map<String, dynamic> map;

      setUp(() {
        map = _minimalPerson().toFirestore();
      });

      test('contains required fields', () {
        expect(map['name'], 'Alice');
        expect(map['dateOfBirth'], '1990-03-15');
        expect(map['relationship'], 'friend');
        expect(map['createdAt'], '2024-01-01T00:00:00Z');
        expect(map['updatedAt'], '2024-01-01T00:00:00Z');
      });

      test('does not contain optional null fields', () {
        expect(map.containsKey('photo'), isFalse);
        expect(map.containsKey('connectedThrough'), isFalse);
        expect(map.containsKey('knownFrom'), isFalse);
        expect(map.containsKey('knownFromCustom'), isFalse);
        expect(map.containsKey('notes'), isFalse);
        expect(map.containsKey('giftIdeas'), isFalse);
        expect(map.containsKey('interests'), isFalse);
        expect(map.containsKey('pastGifts'), isFalse);
        expect(map.containsKey('parties'), isFalse);
        expect(map.containsKey('socialLinks'), isFalse);
        expect(map.containsKey('notificationTimings'), isFalse);
      });
    });

    group('fully-populated person', () {
      late Map<String, dynamic> map;

      setUp(() {
        map = _fullPerson().toFirestore();
      });

      test('serialises photo', () {
        expect(map['photo'], 'https://example.com/photo.jpg');
      });

      test('serialises connectedThrough', () {
        expect(map['connectedThrough'], 'Alice');
      });

      test('serialises knownFrom as firestoreValue', () {
        expect(map['knownFrom'], KnownFrom.school.firestoreValue);
      });

      test('serialises knownFromCustom', () {
        expect(map['knownFromCustom'], 'Primary school');
      });

      test('serialises notes', () {
        expect(map['notes'], 'Loves hiking');
      });

      test('serialises giftIdeas list', () {
        expect(map['giftIdeas'], ['Book', 'Hiking boots']);
      });

      test('serialises interests list', () {
        expect(map['interests'], ['Hiking', 'Photography']);
      });

      test('serialises pastGifts as list of maps', () {
        final pastGifts = map['pastGifts'] as List<dynamic>;
        expect(pastGifts.length, 2);
        expect((pastGifts[0] as Map<String, dynamic>)['description'], 'Book');
        expect((pastGifts[0] as Map<String, dynamic>)['rating'], 4);
        expect((pastGifts[1] as Map<String, dynamic>)['description'], 'Scarf');
      });

      test('serialises parties as list of maps', () {
        final parties = map['parties'] as List<dynamic>;
        expect(parties.length, 2);
        expect((parties[0] as Map<String, dynamic>)['year'], 2023);
        expect((parties[0] as Map<String, dynamic>)['notes'], 'Surprise party');
      });

      test('serialises socialLinks as list of maps', () {
        final links = map['socialLinks'] as List<dynamic>;
        expect(links.length, 1);
        expect((links[0] as Map<String, dynamic>)['platform'], 'instagram');
      });

      test('serialises notificationTimings as list of strings', () {
        expect(map['notificationTimings'], ['1-week', 'on-the-day']);
      });

      test('serialises relationship as firestoreValue', () {
        expect(map['relationship'], 'family');
      });
    });

    group('omits empty collections', () {
      test('does not include empty giftIdeas list', () {
        const person = Person(
          id: 'p',
          name: 'Test',
          dateOfBirth: '2000-01-01',
          relationship: Relationship.other,
          giftIdeas: [],
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        );
        expect(person.toFirestore().containsKey('giftIdeas'), isFalse);
      });

      test('does not include empty interests list', () {
        const person = Person(
          id: 'p',
          name: 'Test',
          dateOfBirth: '2000-01-01',
          relationship: Relationship.other,
          interests: [],
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        );
        expect(person.toFirestore().containsKey('interests'), isFalse);
      });

      test('does not include empty connectedThrough string', () {
        const person = Person(
          id: 'p',
          name: 'Test',
          dateOfBirth: '2000-01-01',
          relationship: Relationship.other,
          connectedThrough: '',
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        );
        expect(person.toFirestore().containsKey('connectedThrough'), isFalse);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Person.copyWith()
  // -------------------------------------------------------------------------
  group('Person.copyWith()', () {
    test('returns equal person when no arguments supplied', () {
      final original = _minimalPerson();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.dateOfBirth, original.dateOfBirth);
      expect(copy.relationship, original.relationship);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
    });

    test('id is always preserved (not in copyWith signature)', () {
      final original = _minimalPerson();
      final copy = original.copyWith(name: 'Different Name');

      expect(copy.id, original.id);
    });

    test('updates name', () {
      final copy = _minimalPerson().copyWith(name: 'Updated Name');
      expect(copy.name, 'Updated Name');
    });

    test('updates dateOfBirth', () {
      final copy = _minimalPerson().copyWith(dateOfBirth: '1995-07-20');
      expect(copy.dateOfBirth, '1995-07-20');
    });

    test('updates relationship', () {
      final copy = _minimalPerson().copyWith(relationship: Relationship.colleague);
      expect(copy.relationship, Relationship.colleague);
    });

    test('updates notes', () {
      final copy = _minimalPerson().copyWith(notes: 'New note');
      expect(copy.notes, 'New note');
    });

    test('updates interests', () {
      final copy = _minimalPerson().copyWith(interests: ['Reading', 'Cycling']);
      expect(copy.interests, ['Reading', 'Cycling']);
    });

    test('updates giftIdeas', () {
      final copy = _minimalPerson().copyWith(giftIdeas: ['Candle']);
      expect(copy.giftIdeas, ['Candle']);
    });

    test('updates updatedAt but preserves createdAt', () {
      final original = _minimalPerson();
      final copy = original.copyWith(updatedAt: '2025-01-01T00:00:00Z');

      expect(copy.updatedAt, '2025-01-01T00:00:00Z');
      expect(copy.createdAt, original.createdAt);
    });

    test('updates knownFrom', () {
      final copy = _minimalPerson().copyWith(knownFrom: KnownFrom.work);
      expect(copy.knownFrom, KnownFrom.work);
    });

    test('updates connectedThrough', () {
      final copy = _minimalPerson().copyWith(connectedThrough: 'Dave');
      expect(copy.connectedThrough, 'Dave');
    });

    test('updates notificationTimings', () {
      final timings = [NotificationTiming.twoWeeks, NotificationTiming.oneDay];
      final copy = _minimalPerson().copyWith(notificationTimings: timings);
      expect(copy.notificationTimings, timings);
    });

    test('updates photo', () {
      final copy = _minimalPerson().copyWith(photo: 'https://example.com/new.jpg');
      expect(copy.photo, 'https://example.com/new.jpg');
    });

    test('preserves unmodified fields when updating one field', () {
      final original = _fullPerson();
      final copy = original.copyWith(name: 'Charlie');

      expect(copy.name, 'Charlie');
      expect(copy.dateOfBirth, original.dateOfBirth);
      expect(copy.relationship, original.relationship);
      expect(copy.photo, original.photo);
      expect(copy.connectedThrough, original.connectedThrough);
      expect(copy.knownFrom, original.knownFrom);
      expect(copy.notes, original.notes);
      expect(copy.interests, original.interests);
      expect(copy.giftIdeas, original.giftIdeas);
    });
  });
}
