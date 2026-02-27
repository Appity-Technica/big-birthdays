import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../models/person.dart';

/// Prepares a single person data map for Firestore by adding timestamps and
/// removing null values. Extracted for testability.
@visibleForTesting
Map<String, dynamic> cleanPersonData(
    Map<String, dynamic> data, String timestamp) {
  return <String, dynamic>{
    ...data,
    'createdAt': timestamp,
    'updatedAt': timestamp,
  }..removeWhere((_, v) => v == null);
}

/// Returns the number of Firestore batch commits required for [itemCount]
/// items given a [batchLimit] (default 500).
@visibleForTesting
int batchCommitCount(int itemCount, {int batchLimit = 500}) {
  if (itemCount <= 0) return 0;
  return (itemCount + batchLimit - 1) ~/ batchLimit;
}

/// Repository for CRUD operations on [Person] documents in Firestore.
///
/// People are stored under `users/{userId}/people` in Firestore.
/// All write methods automatically set `createdAt`/`updatedAt` timestamps
/// and strip `null` values before persisting.
class PeopleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _peopleRef(String userId) =>
      _db.collection('users').doc(userId).collection('people');

  /// Streams all [Person] records for [userId], ordered alphabetically by name.
  Stream<List<Person>> watchPeople(String userId) {
    return _peopleRef(userId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map((doc) => Person.fromFirestore(doc)).toList(),
        );
  }

  /// Fetches a single [Person] by [personId]. Returns `null` if not found.
  Future<Person?> getPerson(String userId, String personId) async {
    final doc = await _peopleRef(userId).doc(personId).get();
    if (!doc.exists) return null;
    return Person.fromFirestore(doc);
  }

  /// Creates a new person document and returns its generated Firestore ID.
  ///
  /// Automatically sets `createdAt` and `updatedAt` to the current time.
  Future<String> addPerson(
      String userId, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final cleanData = cleanPersonData(data, now);
    final docRef = await _peopleRef(userId).add(cleanData);
    return docRef.id;
  }

  /// Updates an existing person document, automatically refreshing `updatedAt`.
  Future<void> updatePerson(
      String userId, String personId, Map<String, dynamic> updates) async {
    final cleanUpdates = <String, dynamic>{
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    }..removeWhere((_, v) => v == null);
    await _peopleRef(userId).doc(personId).update(cleanUpdates);
  }

  /// Permanently deletes a person document from Firestore.
  Future<void> deletePerson(String userId, String personId) async {
    await _peopleRef(userId).doc(personId).delete();
  }

  /// Imports multiple people using Firestore batch writes.
  ///
  /// Automatically commits a new batch every 500 operations to respect
  /// the Firestore batch size limit. Returns the total number of people added.
  Future<int> batchAddPeople(
      String userId, List<Map<String, dynamic>> dataList) async {
    final now = DateTime.now().toIso8601String();
    final ref = _peopleRef(userId);
    var batch = _db.batch();
    var count = 0;

    for (final data in dataList) {
      final cleanData = cleanPersonData(data, now);

      final docRef = ref.doc();
      batch.set(docRef, cleanData);
      count++;

      if (count % 500 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }

    if (count % 500 != 0) {
      await batch.commit();
    }

    return count;
  }
}
