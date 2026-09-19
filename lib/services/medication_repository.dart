import 'dart:convert';

import 'package:meditrack/features/medications/models/medication.dart';
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
