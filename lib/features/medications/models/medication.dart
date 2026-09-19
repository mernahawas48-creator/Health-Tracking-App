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

  bool get hasScheduledReminder {
    return isActive && frequency != MedicationFrequency.asNeeded;
  }

  bool isScheduledFor(DateTime date) {
    if (!hasScheduledReminder) return false;

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final day = DateTime(date.year, date.month, date.day);
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
}
