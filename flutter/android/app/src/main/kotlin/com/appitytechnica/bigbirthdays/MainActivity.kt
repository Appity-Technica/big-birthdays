package com.appitytechnica.bigbirthdays

import android.Manifest
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.appitytechnica.bigbirthdays/contacts"
    private val CONTACTS_PERMISSION_CODE = 100
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getContactsWithBirthdays") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
                    result.success(getContactsWithBirthdays())
                } else {
                    pendingResult = result
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CONTACTS), CONTACTS_PERMISSION_CODE)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CONTACTS_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pendingResult?.success(getContactsWithBirthdays())
            } else {
                pendingResult?.error("PERMISSION_DENIED", "Contacts permission denied", null)
            }
            pendingResult = null
        }
    }

    private fun getContactsWithBirthdays(): List<Map<String, String>> {
        val contacts = mutableListOf<Map<String, String>>()
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Event.CONTACT_ID,
            ContactsContract.CommonDataKinds.Event.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Event.START_DATE,
            ContactsContract.CommonDataKinds.Event.TYPE
        )
        val selection = "${ContactsContract.CommonDataKinds.Event.TYPE} = ? AND ${ContactsContract.Data.MIMETYPE} = ?"
        val selectionArgs = arrayOf(
            ContactsContract.CommonDataKinds.Event.TYPE_BIRTHDAY.toString(),
            ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE
        )

        contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        )?.use { cursor ->
            val nameIdx = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Event.DISPLAY_NAME)
            val dateIdx = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Event.START_DATE)

            while (cursor.moveToNext()) {
                val name = cursor.getString(nameIdx) ?: continue
                val dateStr = cursor.getString(dateIdx) ?: continue
                val dob = parseBirthday(dateStr)
                if (dob != null) {
                    contacts.add(mapOf("name" to name, "dateOfBirth" to dob))
                }
            }
        }
        return contacts
    }

    private fun parseBirthday(dateStr: String): String? {
        // Android stores birthdays as YYYY-MM-DD or --MM-DD (no year)
        val noYear = Regex("^--(\\d{2})-(\\d{2})$")
        val withYear = Regex("^(\\d{4})-(\\d{2})-(\\d{2})$")

        noYear.matchEntire(dateStr)?.let {
            return "0000-${it.groupValues[1]}-${it.groupValues[2]}"
        }
        withYear.matchEntire(dateStr)?.let {
            val year = it.groupValues[1]
            return if (year == "0000") "0000-${it.groupValues[2]}-${it.groupValues[3]}"
            else "$year-${it.groupValues[2]}-${it.groupValues[3]}"
        }
        return null
    }
}
