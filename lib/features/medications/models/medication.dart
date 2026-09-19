import 'dart:convert';

import 'package:flutter/material.dart';

enum MedicationFrequency { daily, everyOtherDay, weekly, asNeeded }

extension MedicationFrequencyLabel on MedicationFrequency {
  String get label {
    switch (this) {
      case MedicationFrequency.daily:
        return 'Daily';
      case MedicationFrequency.everyOtherDay:
        return 'Every other day';
      case MedicationFrequency.weekly:
        return 'Weekly';
      case MedicationFrequency.asNeeded:
        return 'As needed';
    }
  }
}

enum MedicationType {
  tablet,
  capsule,
  injection,
  drops,
  syrup,
  inhaler,
  cream,
  other,
}

extension MedicationTypeDetails on MedicationType {
  String get label {
    switch (this) {
      case MedicationType.tablet:
        return 'Tablet';
      case MedicationType.capsule:
        return 'Capsule';
      case MedicationType.injection:
        return 'Injection';
      case MedicationType.drops:
        return 'Drops';
      case MedicationType.syrup:
        return 'Syrup';
      case MedicationType.inhaler:
        return 'Inhaler';
      case MedicationType.cream:
        return 'Cream';
      case MedicationType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return Icons.medication_rounded;
      case MedicationType.injection:
        return Icons.vaccines_rounded;
      case MedicationType.drops:
        return Icons.water_drop_rounded;
      case MedicationType.syrup:
        return Icons.local_drink_rounded;
      case MedicationType.inhaler:
        return Icons.air_rounded;
      case MedicationType.cream:
        return Icons.medical_services_rounded;
      case MedicationType.other:
        return Icons.health_and_safety_rounded;
    }
  }
}

enum MealRelation { beforeMeal, afterMeal, anyTime }

extension MealRelationLabel on MealRelation {
  String get label {
    switch (this) {
      case MealRelation.beforeMeal:
        return 'Before meal';
      case MealRelation.afterMeal:
        return 'After meal';
      case MealRelation.anyTime:
        return 'Any time';
    }
  }
}

enum DoseStatus { pending, taken, skipped }

extension DoseStatusDetails on DoseStatus {
  String get label {
    switch (this) {
      case DoseStatus.pending:
        return 'Pending';
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.skipped:
        return 'Skipped';
    }
  }

  IconData get icon {
    switch (this) {
      case DoseStatus.pending:
        return Icons.schedule_rounded;
      case DoseStatus.taken:
        return Icons.check_circle_rounded;
      case DoseStatus.skipped:
        return Icons.remove_circle_outline_rounded;
    }
  }
}

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.time,
    required this.mealRelation,
    this.isActive = true,
    this.doseStatuses = const {},
  });

  final String id;
  final String name;
  final MedicationType type;
  final String dosage;
  final MedicationFrequency frequency;
  final DateTime startDate;
  final TimeOfDay time;
  final MealRelation mealRelation;
  final bool isActive;

  /// The key is `yyyy-MM-dd`; it keeps a local record for each scheduled dose.
  final Map<String, DoseStatus> doseStatuses;

  bool get hasScheduledReminder {
    return isActive && frequency != MedicationFrequency.asNeeded;
  }

  bool isScheduledFor(DateTime date) {
    if (!hasScheduledReminder) return false;

    final start = _dateOnly(startDate);
    final day = _dateOnly(date);
    if (day.isBefore(start)) return false;

    final daysSinceStart = day.difference(start).inDays;
    switch (frequency) {
      case MedicationFrequency.daily:
        return true;
      case MedicationFrequency.everyOtherDay:
        return daysSinceStart % 2 == 0;
      case MedicationFrequency.weekly:
        return daysSinceStart % 7 == 0;
      case MedicationFrequency.asNeeded:
        return false;
    }
  }

  DoseStatus statusOn(DateTime date) {
    return doseStatuses[_dateKey(date)] ?? DoseStatus.pending;
  }

  Medication withStatus(DateTime date, DoseStatus status) {
    final updatedStatuses = Map<String, DoseStatus>.from(doseStatuses)
      ..[_dateKey(date)] = status;
    return copyWith(doseStatuses: updatedStatuses);
  }

  Medication copyWith({bool? isActive, Map<String, DoseStatus>? doseStatuses}) {
    return Medication(
      id: id,
      name: name,
      type: type,
      dosage: dosage,
      frequency: frequency,
      startDate: startDate,
      time: time,
      mealRelation: mealRelation,
      isActive: isActive ?? this.isActive,
      doseStatuses: doseStatuses ?? this.doseStatuses,
    );
  }

  DateTime nextDoseAfter(DateTime date) {
    var candidate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    while (!candidate.isAfter(date) || !isScheduledFor(candidate)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'dosage': dosage,
    'frequency': frequency.name,
    'startDate': startDate.toIso8601String(),
    'hour': time.hour,
    'minute': time.minute,
    'mealRelation': mealRelation.name,
    'isActive': isActive,
    'doseStatuses': doseStatuses.map((key, value) => MapEntry(key, value.name)),
  };

  String toStorageValue() => jsonEncode(toJson());

  factory Medication.fromJson(Map<String, dynamic> json) {
    final rawStatuses =
        (json['doseStatuses'] as Map? ?? const <String, dynamic>{});
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MedicationType.values.byName(json['type'] as String),
      dosage: json['dosage'] as String,
      frequency: MedicationFrequency.values.byName(json['frequency'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      time: TimeOfDay(
        hour: (json['hour'] as num).toInt(),
        minute: (json['minute'] as num).toInt(),
      ),
      mealRelation: MealRelation.values.byName(json['mealRelation'] as String),
      isActive: json['isActive'] as bool? ?? true,
      doseStatuses: rawStatuses.map(
        (key, value) => MapEntry(
          key.toString(),
          DoseStatus.values.byName(value.toString()),
        ),
      ),
    );
  }

  static String _dateKey(DateTime date) {
    final day = _dateOnly(date);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
