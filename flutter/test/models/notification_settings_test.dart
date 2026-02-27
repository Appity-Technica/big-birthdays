import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/models/notification_settings.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  group('NotificationSettings.fromMap', () {
    test('parses fully-populated map', () {
      final settings = NotificationSettings.fromMap({
        'enabled': true,
        'defaultTimings': ['on-the-day', '1-week'],
        'fcmToken': 'abc123',
      });

      expect(settings.enabled, isTrue);
      expect(settings.defaultTimings, [
        NotificationTiming.onTheDay,
        NotificationTiming.oneWeek,
      ]);
      expect(settings.fcmToken, 'abc123');
    });

    test('defaults enabled to false when absent', () {
      final settings = NotificationSettings.fromMap({});

      expect(settings.enabled, isFalse);
    });

    test('defaults enabled to false when null', () {
      final settings = NotificationSettings.fromMap({'enabled': null});

      expect(settings.enabled, isFalse);
    });

    test('defaults defaultTimings to empty list when absent', () {
      final settings = NotificationSettings.fromMap({});

      expect(settings.defaultTimings, isEmpty);
    });

    test('defaults defaultTimings to empty list when null', () {
      final settings = NotificationSettings.fromMap({'defaultTimings': null});

      expect(settings.defaultTimings, isEmpty);
    });

    test('fcmToken is null when absent', () {
      final settings = NotificationSettings.fromMap({'enabled': false});

      expect(settings.fcmToken, isNull);
    });

    test('parses all timing values', () {
      final settings = NotificationSettings.fromMap({
        'enabled': true,
        'defaultTimings': [
          'on-the-day',
          '1-day',
          '3-days',
          '1-week',
          '2-weeks',
        ],
      });

      expect(settings.defaultTimings, [
        NotificationTiming.onTheDay,
        NotificationTiming.oneDay,
        NotificationTiming.threeDays,
        NotificationTiming.oneWeek,
        NotificationTiming.twoWeeks,
      ]);
    });
  });

  group('NotificationSettings.toMap', () {
    test('serialises all fields when fcmToken is present', () {
      const settings = NotificationSettings(
        enabled: true,
        defaultTimings: [NotificationTiming.oneDay, NotificationTiming.threeDays],
        fcmToken: 'token-xyz',
      );
      final map = settings.toMap();

      expect(map['enabled'], isTrue);
      expect(map['defaultTimings'], ['1-day', '3-days']);
      expect(map['fcmToken'], 'token-xyz');
    });

    test('omits fcmToken when null', () {
      const settings = NotificationSettings(
        enabled: false,
        defaultTimings: [],
      );
      final map = settings.toMap();

      expect(map.containsKey('fcmToken'), isFalse);
    });

    test('serialises empty timings as empty list', () {
      const settings = NotificationSettings(
        enabled: true,
        defaultTimings: [],
      );
      final map = settings.toMap();

      expect(map['defaultTimings'], isEmpty);
    });
  });

  group('NotificationSettings round-trip', () {
    test('fromMap(toMap()) preserves all fields', () {
      const original = NotificationSettings(
        enabled: true,
        defaultTimings: [
          NotificationTiming.onTheDay,
          NotificationTiming.twoWeeks,
        ],
        fcmToken: 'my-token',
      );
      final restored = NotificationSettings.fromMap(original.toMap());

      expect(restored.enabled, original.enabled);
      expect(restored.defaultTimings, original.defaultTimings);
      expect(restored.fcmToken, original.fcmToken);
    });

    test('fromMap(toMap()) preserves disabled state with no timings', () {
      const original = NotificationSettings(
        enabled: false,
        defaultTimings: [],
      );
      final restored = NotificationSettings.fromMap(original.toMap());

      expect(restored.enabled, isFalse);
      expect(restored.defaultTimings, isEmpty);
      expect(restored.fcmToken, isNull);
    });
  });

  group('NotificationSettings.copyWith', () {
    const base = NotificationSettings(
      enabled: true,
      defaultTimings: [NotificationTiming.onTheDay],
      fcmToken: 'original-token',
    );

    test('no args returns equivalent instance', () {
      final copy = base.copyWith();

      expect(copy.enabled, base.enabled);
      expect(copy.defaultTimings, base.defaultTimings);
      expect(copy.fcmToken, base.fcmToken);
    });

    test('updates enabled', () {
      final copy = base.copyWith(enabled: false);

      expect(copy.enabled, isFalse);
      expect(copy.defaultTimings, base.defaultTimings);
      expect(copy.fcmToken, base.fcmToken);
    });

    test('updates defaultTimings', () {
      final copy = base.copyWith(
        defaultTimings: [NotificationTiming.oneWeek, NotificationTiming.twoWeeks],
      );

      expect(copy.defaultTimings, [
        NotificationTiming.oneWeek,
        NotificationTiming.twoWeeks,
      ]);
      expect(copy.enabled, base.enabled);
    });

    test('updates fcmToken', () {
      final copy = base.copyWith(fcmToken: 'new-token');

      expect(copy.fcmToken, 'new-token');
      expect(copy.enabled, base.enabled);
    });
  });
}
