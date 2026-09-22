import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/services/medication_repository.dart';

class MedicationState {
  const MedicationState({
    this.medications = const [],
    this.loading = false,
    this.error,
  });
  final List<Medication> medications;
  final bool loading;
  final String? error;
  MedicationAdherenceSummary get todaySummary =>
      MedicationAdherenceService.summaryForToday(medications);
}

class MedicationCubit extends Cubit<MedicationState> {
  MedicationCubit(this._repository, this._notifications)
    : super(const MedicationState());
  final MedicationRepository _repository;
  final MedicationNotificationService _notifications;

  Future<void> load() async {
    emit(MedicationState(medications: state.medications, loading: true));
    try {
      emit(MedicationState(medications: await _repository.load()));
    } catch (_) {
      emit(
        MedicationState(medications: state.medications, error: 'medications'),
      );
    }
  }

  Future<bool> add(Medication medication) =>
      _save([...state.medications, medication]);

  Future<bool> update(Medication medication) => _save([
    for (final item in state.medications)
      if (item.id == medication.id) medication else item,
  ]);

  Future<bool> delete(Medication medication) async {
    final saved = await _save(
      state.medications.where((item) => item.id != medication.id).toList(),
    );
    if (!saved) return false;
    try {
      await _notifications.cancel(medication);
    } catch (_) {}
    return true;
  }

  Future<bool> _save(List<Medication> medications) async {
    try {
      await _repository.save(medications);
      emit(MedicationState(medications: List.unmodifiable(medications)));
      for (final medication in medications) {
        try {
          await _notifications.sync(medication);
        } catch (_) {
          // Saved medication remains usable if the platform denies alerts.
        }
      }
      return true;
    } catch (_) {
      emit(
        MedicationState(medications: state.medications, error: 'medications'),
      );
      return false;
    }
  }
}
