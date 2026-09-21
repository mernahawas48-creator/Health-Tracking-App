import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Keeps medication alerts on the device. Firebase is not required.
class MedicationNotificationService {
  MedicationNotificationService._();
  static final instance = MedicationNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/notification_icon'),
    ));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  int _notificationId(Medication medication) => medication.id.hashCode & 0x7fffffff;

  Future<void> sync(Medication medication) async {
    await cancel(medication);
    if (!medication.hasScheduledReminder) return;
    final now = DateTime.now();
    final next = medication.nextDoseAfter(now);
    await _plugin.zonedSchedule(
      _notificationId(medication),
      'Medication reminder',
      '${medication.name} • ${medication.dosage}',
      tz.TZDateTime.from(next, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('medication_reminders', 'Medication reminders', channelDescription: 'Scheduled reminders for medication doses', importance: Importance.high, priority: Priority.high),
      ),
      // Exact alarms can be denied by Android/emulators. An inexact reminder
      // still delivers reliably without making medication saving fail.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: medication.frequency == MedicationFrequency.daily
          ? DateTimeComponents.time
          : null,
    );
  }

  Future<void> cancel(Medication medication) async {
    try {
      await _plugin.cancel(_notificationId(medication));
    } catch (_) {
      // Local medication data must remain usable if notifications are unavailable.
    }
  }
}
