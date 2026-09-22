import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/medication_cubit.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/notification_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('local notification records and read state survive restart', () async {
    final createdAt = DateTime(2026, 9, 22, 9);
    final repository = NotificationStateRepository();
    await repository.add(
      LocalAlert(
        id: 'med-1',
        title: 'Medication reminder saved',
        body: 'Vitamin D • 08:00 AM',
        type: 'medication',
        createdAt: createdAt,
      ),
    );
    await repository.add(
      LocalAlert(
        id: 'water-1',
        title: 'Water reminder',
        body: 'Time for a glass of water.',
        type: 'wellness',
        createdAt: createdAt.add(const Duration(minutes: 1)),
      ),
    );

    final restarted = NotificationStateRepository();
    final alerts = await restarted.load();
    expect(alerts.map((alert) => alert.id), ['water-1', 'med-1']);
    expect(alerts.every((alert) => !alert.read), isTrue);

    await restarted.markRead('med-1');
    var restored = await NotificationStateRepository().load();
    expect(restored.singleWhere((alert) => alert.id == 'med-1').read, isTrue);
    expect(
      restored.singleWhere((alert) => alert.id == 'water-1').read,
      isFalse,
    );

    await restarted.markAllRead();
    restored = await NotificationStateRepository().load();
    expect(restored.every((alert) => alert.read), isTrue);
  });

  test(
    'saving a scheduled medication creates one useful local alert',
    () async {
      final alerts = NotificationStateRepository();
      final cubit = MedicationCubit(
        MedicationRepository(),
        MedicationNotificationService.instance,
        alerts: alerts,
      );
      addTearDown(cubit.close);
      await cubit.add(
        Medication(
          id: 'vitamin-d',
          name: 'Vitamin D',
          type: MedicationType.tablet,
          dosage: '1 tablet',
          frequency: MedicationFrequency.daily,
          startDate: DateTime.now(),
          time: const TimeOfDay(hour: 8, minute: 0),
          mealRelation: MealRelation.anyTime,
        ),
      );
      final alert = (await alerts.load()).single;
      expect(alert.id, 'medication-reminder-vitamin-d');
      expect(alert.type, 'medication');
      expect(alert.read, isFalse);
    },
  );
}
