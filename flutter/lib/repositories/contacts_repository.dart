import 'package:flutter/services.dart';

class DeviceContact {
  final String name;
  final String dateOfBirth; // YYYY-MM-DD or 0000-MM-DD

  const DeviceContact({required this.name, required this.dateOfBirth});
}

class ContactsRepository {
  static const _channel = MethodChannel('com.appitytechnica.bigbirthdays/contacts');

  Future<List<DeviceContact>> getContactsWithBirthdays() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getContactsWithBirthdays');
      return result.map((c) {
        final map = Map<String, dynamic>.from(c);
        return DeviceContact(
          name: map['name'] as String,
          dateOfBirth: map['dateOfBirth'] as String,
        );
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') return [];
      rethrow;
    }
  }
}
