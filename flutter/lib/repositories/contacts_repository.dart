import 'package:flutter/services.dart';

/// A contact from the device's native address book that has a birthday.
class DeviceContact {
  /// The contact's display name.
  final String name;

  /// Date of birth in `YYYY-MM-DD` format. Year `0000` means the native
  /// contact did not have a birth year, only month and day.
  final String dateOfBirth; // YYYY-MM-DD or 0000-MM-DD

  const DeviceContact({required this.name, required this.dateOfBirth});
}

/// Repository for reading contacts from the device's native address book.
///
/// Uses a platform [MethodChannel] to invoke native iOS/Android code that
/// reads contacts with birthdays. Requires contacts permission to be granted
/// by the user; returns an empty list if permission is denied.
class ContactsRepository {
  static const _channel = MethodChannel('com.appitytechnica.bigbirthdays/contacts');

  /// Fetches all device contacts that have a birthday set, sorted
  /// alphabetically by name.
  ///
  /// Returns an empty list if the user has denied contacts permission.
  /// Rethrows any [PlatformException] other than `PERMISSION_DENIED`.
  Future<List<DeviceContact>> getContactsWithBirthdays() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getContactsWithBirthdays');
      return result.map((c) {
        final map = Map<String, dynamic>.from(c);
        return DeviceContact(
          name: (map['name'] as String?) ?? '',
          dateOfBirth: (map['dateOfBirth'] as String?) ?? '',
        );
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') return [];
      rethrow;
    }
  }
}
