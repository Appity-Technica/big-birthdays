import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static final instance = FirebaseAnalytics.instance;
  static final observer = FirebaseAnalyticsObserver(analytics: instance);

  static Future<void> logSignUp() =>
      instance.logSignUp(signUpMethod: 'email');

  static Future<void> logGoogleSignUp() =>
      instance.logSignUp(signUpMethod: 'google');

  static Future<void> logAddPerson() =>
      instance.logEvent(name: 'add_person');

  static Future<void> logEditPerson() =>
      instance.logEvent(name: 'edit_person');

  static Future<void> logDeletePerson() =>
      instance.logEvent(name: 'delete_person');

  static Future<void> logRequestGiftSuggestions() =>
      instance.logEvent(name: 'request_gift_suggestions');

  static Future<void> logImportContacts({required int count}) =>
      instance.logEvent(
        name: 'import_contacts',
        parameters: {'count': count},
      );

  static Future<void> logExportPeople({required int count}) =>
      instance.logEvent(
        name: 'export_people',
        parameters: {'count': count},
      );

  static Future<void> logSharePerson() =>
      instance.logEvent(name: 'share_person');
}
