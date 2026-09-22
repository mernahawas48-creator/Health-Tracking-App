import 'dart:convert';

import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/services/account_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationRepository {
  static const _storageKey = 'medications_v1';

  Future<List<Medication>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_storageKey) ?? [];
    final medications = <Medication>[];

    for (final value in values) {
      try {
        medications.add(
          Medication.fromJson(jsonDecode(value) as Map<String, dynamic>),
        );
      } on FormatException {
        // Ignore an old/corrupted record instead of blocking the whole page.
      }
    }
    return medications;
  }

  Future<void> save(List<Medication> medications) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      medications.map((medication) => medication.toStorageValue()).toList(),
    );
  }
}

/// Production persistence. The local base remains usable by deterministic tests.
class FirestoreMedicationRepository extends MedicationRepository {
  FirestoreMedicationRepository(this._account);
  final AccountFirestore _account;

  @override
  Future<List<Medication>> load() async {
    final uid = _account.uid;
    final snapshot = await _account.user(uid).collection('medications').get();
    await _account.assertOwner(uid);
    return snapshot.docs.map((doc) => Medication.fromJson(doc.data())).toList();
  }

  @override
  Future<void> save(List<Medication> medications) async {
    final uid = _account.uid;
    final collection = _account.user(uid).collection('medications');
    final previous = await collection.get();
    await _account.assertOwner(uid);
    final batch = collection.firestore.batch();
    final ids = medications.map((item) => item.id).toSet();
    for (final doc in previous.docs) {
      if (!ids.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final medication in medications) {
      batch.set(collection.doc(medication.id), medication.toJson());
    }
    await _account.assertOwner(uid);
    await batch.commit();
  }
}
