import 'package:flutter_contacts/flutter_contacts.dart';

class DeviceContact {
  final String name;
  final String dateOfBirth; // YYYY-MM-DD or 0000-MM-DD

  const DeviceContact({required this.name, required this.dateOfBirth});
}

class ContactsRepository {
  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<DeviceContact>> getContactsWithBirthdays() async {
    if (!await FlutterContacts.requestPermission()) return [];

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final results = <DeviceContact>[];
    for (final contact in contacts) {
      for (final event in contact.events) {
        if (event.label == EventLabel.birthday) {
          final year = event.year;
          final yearStr =
              year != null ? year.toString().padLeft(4, '0') : '0000';
          final month = event.month.toString().padLeft(2, '0');
          final day = event.day.toString().padLeft(2, '0');
          results.add(DeviceContact(
            name: contact.displayName,
            dateOfBirth: '$yearStr-$month-$day',
          ));
          break;
        }
      }
    }

    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }
}
