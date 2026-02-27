import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  group('Relationship', () {
    group('fromFirestore', () {
      test('returns family for "family"', () {
        expect(Relationship.fromFirestore('family'), Relationship.family);
      });

      test('returns friend for "friend"', () {
        expect(Relationship.fromFirestore('friend'), Relationship.friend);
      });

      test('returns colleague for "colleague"', () {
        expect(Relationship.fromFirestore('colleague'), Relationship.colleague);
      });

      test('returns other for "other"', () {
        expect(Relationship.fromFirestore('other'), Relationship.other);
      });

      test('returns other for null', () {
        expect(Relationship.fromFirestore(null), Relationship.other);
      });

      test('returns other for unrecognised value', () {
        expect(Relationship.fromFirestore('unknown-value'), Relationship.other);
      });
    });

    group('firestoreValue round-trip', () {
      for (final rel in Relationship.values) {
        test('${rel.name} round-trips through firestoreValue -> fromFirestore', () {
          final serialised = rel.firestoreValue;
          final deserialised = Relationship.fromFirestore(serialised);
          expect(deserialised, rel);
        });
      }
    });

    group('displayLabel', () {
      test('family has display label "Family"', () {
        expect(Relationship.family.displayLabel, 'Family');
      });

      test('friend has display label "Friend"', () {
        expect(Relationship.friend.displayLabel, 'Friend');
      });

      test('colleague has display label "Colleague"', () {
        expect(Relationship.colleague.displayLabel, 'Colleague');
      });

      test('other has display label "Other"', () {
        expect(Relationship.other.displayLabel, 'Other');
      });
    });
  });

  group('KnownFrom', () {
    group('fromFirestore', () {
      test('returns null for null', () {
        expect(KnownFrom.fromFirestore(null), isNull);
      });

      test('returns school for "school"', () {
        expect(KnownFrom.fromFirestore('school'), KnownFrom.school);
      });

      test('returns dance for "dance"', () {
        expect(KnownFrom.fromFirestore('dance'), KnownFrom.dance);
      });

      test('returns sports for "sports"', () {
        expect(KnownFrom.fromFirestore('sports'), KnownFrom.sports);
      });

      test('returns scouts for "scouts"', () {
        expect(KnownFrom.fromFirestore('scouts'), KnownFrom.scouts);
      });

      test('returns neighbourhood for "neighbourhood"', () {
        expect(KnownFrom.fromFirestore('neighbourhood'), KnownFrom.neighbourhood);
      });

      test('returns work for "work"', () {
        expect(KnownFrom.fromFirestore('work'), KnownFrom.work);
      });

      test('returns church for "church"', () {
        expect(KnownFrom.fromFirestore('church'), KnownFrom.church);
      });

      test('returns familyFriend for "family-friend"', () {
        expect(KnownFrom.fromFirestore('family-friend'), KnownFrom.familyFriend);
      });

      test('returns other for "other"', () {
        expect(KnownFrom.fromFirestore('other'), KnownFrom.other);
      });

      test('returns other for unrecognised value', () {
        expect(KnownFrom.fromFirestore('unknown-value'), KnownFrom.other);
      });
    });

    group('firestoreValue', () {
      test('familyFriend serialises to "family-friend" (not enum name)', () {
        expect(KnownFrom.familyFriend.firestoreValue, 'family-friend');
      });

      test('school serialises to "school"', () {
        expect(KnownFrom.school.firestoreValue, 'school');
      });
    });

    group('firestoreValue round-trip', () {
      for (final kf in KnownFrom.values) {
        test('${kf.name} round-trips through firestoreValue -> fromFirestore', () {
          final serialised = kf.firestoreValue;
          final deserialised = KnownFrom.fromFirestore(serialised);
          expect(deserialised, kf);
        });
      }
    });

    group('displayLabel', () {
      test('familyFriend has display label "Family friend"', () {
        expect(KnownFrom.familyFriend.displayLabel, 'Family friend');
      });

      test('neighbourhood has display label "Neighbourhood"', () {
        expect(KnownFrom.neighbourhood.displayLabel, 'Neighbourhood');
      });

      test('school capitalises first letter', () {
        expect(KnownFrom.school.displayLabel, 'School');
      });

      test('work capitalises first letter', () {
        expect(KnownFrom.work.displayLabel, 'Work');
      });
    });
  });

  group('NotificationTiming', () {
    group('fromFirestore', () {
      test('returns onTheDay for "on-the-day"', () {
        expect(NotificationTiming.fromFirestore('on-the-day'),
            NotificationTiming.onTheDay);
      });

      test('returns oneDay for "1-day"', () {
        expect(NotificationTiming.fromFirestore('1-day'),
            NotificationTiming.oneDay);
      });

      test('returns threeDays for "3-days"', () {
        expect(NotificationTiming.fromFirestore('3-days'),
            NotificationTiming.threeDays);
      });

      test('returns oneWeek for "1-week"', () {
        expect(NotificationTiming.fromFirestore('1-week'),
            NotificationTiming.oneWeek);
      });

      test('returns twoWeeks for "2-weeks"', () {
        expect(NotificationTiming.fromFirestore('2-weeks'),
            NotificationTiming.twoWeeks);
      });

      test('returns onTheDay as default for unrecognised value', () {
        expect(NotificationTiming.fromFirestore('unknown-value'),
            NotificationTiming.onTheDay);
      });
    });

    group('firestoreValue', () {
      test('onTheDay serialises to "on-the-day"', () {
        expect(NotificationTiming.onTheDay.firestoreValue, 'on-the-day');
      });

      test('oneDay serialises to "1-day"', () {
        expect(NotificationTiming.oneDay.firestoreValue, '1-day');
      });

      test('threeDays serialises to "3-days"', () {
        expect(NotificationTiming.threeDays.firestoreValue, '3-days');
      });

      test('oneWeek serialises to "1-week"', () {
        expect(NotificationTiming.oneWeek.firestoreValue, '1-week');
      });

      test('twoWeeks serialises to "2-weeks"', () {
        expect(NotificationTiming.twoWeeks.firestoreValue, '2-weeks');
      });
    });

    group('firestoreValue round-trip', () {
      for (final timing in NotificationTiming.values) {
        test('${timing.name} round-trips through firestoreValue -> fromFirestore', () {
          final serialised = timing.firestoreValue;
          final deserialised = NotificationTiming.fromFirestore(serialised);
          expect(deserialised, timing);
        });
      }
    });

    group('displayLabel', () {
      test('onTheDay has display label "On the day"', () {
        expect(NotificationTiming.onTheDay.displayLabel, 'On the day');
      });

      test('oneDay has display label "1 day before"', () {
        expect(NotificationTiming.oneDay.displayLabel, '1 day before');
      });

      test('threeDays has display label "3 days before"', () {
        expect(NotificationTiming.threeDays.displayLabel, '3 days before');
      });

      test('oneWeek has display label "1 week before"', () {
        expect(NotificationTiming.oneWeek.displayLabel, '1 week before');
      });

      test('twoWeeks has display label "2 weeks before"', () {
        expect(NotificationTiming.twoWeeks.displayLabel, '2 weeks before');
      });
    });
  });
}
