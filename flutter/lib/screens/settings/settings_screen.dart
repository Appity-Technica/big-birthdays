import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../models/enums.dart';
import '../../models/notification_settings.dart' as ns;
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_spinner.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _enabled = false;
  Set<NotificationTiming> _timings = {
    NotificationTiming.onTheDay,
    NotificationTiming.oneDay,
  };
  String? _fcmToken;
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final settings = await ref
        .read(settingsRepositoryProvider)
        .getSettings(user.uid);

    if (settings != null) {
      _enabled = settings.enabled;
      _timings = settings.defaultTimings.toSet();
      _fcmToken = settings.fcmToken;
    }
    setState(() => _loading = false);
  }

  Future<void> _toggleEnabled() async {
    if (!_enabled) {
      // Request permission and get token
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await messaging.getToken();
        setState(() {
          _fcmToken = token;
          _enabled = true;
        });
      }
    } else {
      setState(() => _enabled = false);
    }
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _saving = true);

    final settings = ns.NotificationSettings(
      enabled: _enabled,
      defaultTimings: _timings.toList(),
      fcmToken: _fcmToken,
    );

    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(user.uid, settings);

    setState(() {
      _saving = false;
      _saved = true;
    });
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _saved = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSpinner());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Push notifications toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lavender),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _enabled,
                  onChanged: (_) => _toggleEnabled(),
                  title: const Text('Push Notifications',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text(
                    'Get reminded about upcoming birthdays',
                    style: TextStyle(fontSize: 12),
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timing options
          if (_enabled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('When to notify (defaults)',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'These apply to all people unless overridden individually.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.foreground.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...NotificationTiming.values.map((t) => CheckboxListTile(
                        value: _timings.contains(t),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _timings.add(t);
                            } else {
                              _timings.remove(t);
                            }
                          });
                        },
                        title: Text(t.displayLabel,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.teal,
                        dense: true,
                      )),
                  if (_timings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Select at least one timing option.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _saving || (_enabled && _timings.isEmpty) ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : _saved
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 18),
                            SizedBox(width: 8),
                            Text('Saved!'),
                          ],
                        )
                      : const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
