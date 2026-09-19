import 'package:meditrack/features/medications/models/medication.dart';

class MedicationAdherenceSummary {
  const MedicationAdherenceSummary({
    required this.scheduledCount,
    required this.takenCount,
    required this.skippedCount,
    required this.pendingCount,
    required this.streakDays,
  });

  final int scheduledCount;
  final int takenCount;
  final int skippedCount;
  final int pendingCount;
  final int streakDays;

  bool get isComplete =>
      scheduledCount > 0 && pendingCount == 0 && skippedCount == 0;
  double get completionRate =>
      scheduledCount == 0 ? 0 : takenCount / scheduledCount;
}

class MedicationAdherenceService {
  static MedicationAdherenceSummary summaryForToday(
    List<Medication> medications,
  ) {
    final now = DateTime.now();
    final scheduled = medications
        .where((medication) => medication.isScheduledFor(now))
        .toList();
    final statuses = scheduled.map((medication) => medication.statusOn(now));

    return MedicationAdherenceSummary(
      scheduledCount: scheduled.length,
      takenCount: statuses.where((status) => status == DoseStatus.taken).length,
      skippedCount: statuses
          .where((status) => status == DoseStatus.skipped)
          .length,
      pendingCount: statuses
          .where((status) => status == DoseStatus.pending)
          .length,
      streakDays: currentStreak(medications),
    );
  }

  static int currentStreak(List<Medication> medications) {
    var day = _dateOnly(DateTime.now());
    if (!_isFullyCompleted(medications, day)) {
      day = day.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (_isFullyCompleted(medications, day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static bool _isFullyCompleted(List<Medication> medications, DateTime date) {
    final scheduled = medications
        .where((medication) => medication.isScheduledFor(date))
        .toList();
    return scheduled.isNotEmpty &&
        scheduled.every(
          (medication) => medication.statusOn(date) == DoseStatus.taken,
        );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
