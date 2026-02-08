import Flutter
import UIKit
import Contacts

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let contactsChannel = FlutterMethodChannel(
      name: "com.appitytechnica.bigbirthdays/contacts",
      binaryMessenger: controller.binaryMessenger
    )

    contactsChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getContactsWithBirthdays" {
        self?.getContactsWithBirthdays(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getContactsWithBirthdays(result: @escaping FlutterResult) {
    let store = CNContactStore()
    store.requestAccess(for: .contacts) { granted, error in
      if !granted {
        DispatchQueue.main.async {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Contacts permission denied", details: nil))
        }
        return
      }

      let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey] as [CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keys)
      var contacts: [[String: String]] = []

      do {
        try store.enumerateContacts(with: request) { contact, _ in
          guard let birthday = contact.birthday,
                let month = birthday.month,
                let day = birthday.day else { return }
          let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
          guard !name.isEmpty else { return }

          let year: String
          if let y = birthday.year, y > 0 {
            year = String(format: "%04d", y)
          } else {
            year = "0000"
          }
          let monthStr = String(format: "%02d", month)
          let dayStr = String(format: "%02d", day)

          contacts.append([
            "name": name,
            "dateOfBirth": "\(year)-\(monthStr)-\(dayStr)"
          ])
        }
        DispatchQueue.main.async {
          result(contacts)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
}
