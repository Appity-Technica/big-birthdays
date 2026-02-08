import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';

class PeopleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _peopleRef(String userId) =>
      _db.collection('users').doc(userId).collection('people');

  Stream<List<Person>> watchPeople(String userId) {
    return _peopleRef(userId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map((doc) => Person.fromFirestore(doc)).toList(),
        );
  }

  Future<Person?> getPerson(String userId, String personId) async {
    final doc = await _peopleRef(userId).doc(personId).get();
    if (!doc.exists) return null;
    return Person.fromFirestore(doc);
  }

  Future<String> addPerson(
      String userId, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final cleanData = <String, dynamic>{
      ...data,
      'createdAt': now,
      'updatedAt': now,
    }..removeWhere((_, v) => v == null);
    final docRef = await _peopleRef(userId).add(cleanData);
    return docRef.id;
  }

  Future<void> updatePerson(
      String userId, String personId, Map<String, dynamic> updates) async {
    final cleanUpdates = <String, dynamic>{
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    }..removeWhere((_, v) => v == null);
    await _peopleRef(userId).doc(personId).update(cleanUpdates);
  }

  Future<void> deletePerson(String userId, String personId) async {
    await _peopleRef(userId).doc(personId).delete();
  }
}
