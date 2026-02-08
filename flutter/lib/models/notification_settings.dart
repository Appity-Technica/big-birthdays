import 'enums.dart';

class NotificationSettings {
  final bool enabled;
  final List<NotificationTiming> defaultTimings;
  final String? fcmToken;

  const NotificationSettings({
    required this.enabled,
    required this.defaultTimings,
    this.fcmToken,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] as bool? ?? false,
      defaultTimings: (map['defaultTimings'] as List<dynamic>?)
              ?.map((e) => NotificationTiming.fromFirestore(e as String))
              .toList() ??
          [],
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'enabled': enabled,
      'defaultTimings':
          defaultTimings.map((t) => t.firestoreValue).toList(),
    };
    if (fcmToken != null) map['fcmToken'] = fcmToken;
    return map;
  }

  NotificationSettings copyWith({
    bool? enabled,
    List<NotificationTiming>? defaultTimings,
    String? fcmToken,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      defaultTimings: defaultTimings ?? this.defaultTimings,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
