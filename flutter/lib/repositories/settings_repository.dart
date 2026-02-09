import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_settings.dart';
import '../models/user_preferences.dart';

class SettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _notifDoc(String userId) =>
      _db.collection('users').doc(userId).collection('settings').doc('notifications');

  DocumentReference<Map<String, dynamic>> _prefsDoc(String userId) =>
      _db.collection('users').doc(userId).collection('settings').doc('preferences');

  Future<NotificationSettings?> getSettings(String userId) async {
    final doc = await _notifDoc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return NotificationSettings.fromMap(doc.data()!);
  }

  Future<void> saveSettings(
      String userId, NotificationSettings settings) async {
    await _notifDoc(userId).set(settings.toMap());
  }

  Future<UserPreferences> getPreferences(String userId) async {
    final doc = await _prefsDoc(userId).get();
    if (!doc.exists || doc.data() == null) return const UserPreferences();
    return UserPreferences.fromMap(doc.data()!);
  }

  Future<void> savePreferences(
      String userId, UserPreferences prefs) async {
    await _prefsDoc(userId).set(prefs.toMap());
  }
}
