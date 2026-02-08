import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../repositories/settings_repository.dart';
import 'auth_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final notificationSettingsProvider =
    FutureProvider<NotificationSettings?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(settingsRepositoryProvider).getSettings(user.uid);
});
