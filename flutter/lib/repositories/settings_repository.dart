import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_settings.dart';

class SettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _notifDoc(String userId) =>
      _db.collection('users').doc(userId).collection('settings').doc('notifications');

  Future<NotificationSettings?> getSettings(String userId) async {
    final doc = await _notifDoc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return NotificationSettings.fromMap(doc.data()!);
  }

  Future<void> saveSettings(
      String userId, NotificationSettings settings) async {
    await _notifDoc(userId).set(settings.toMap());
  }
}
