import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Keeps medication alerts on the device. Firebase is not required.
class MedicationNotificationService {
  static const waterReminderId = 9001;
  static const sleepReminderId = 9002;
  MedicationNotificationService._();
  static final instance = MedicationNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/notification_icon'),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  int _notificationId(Medication medication) =>
      medication.id.hashCode & 0x7fffffff;

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
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication reminders',
          channelDescription: 'Scheduled reminders for medication doses',
          importance: Importance.high,
          priority: Priority.high,
        ),
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

  Future<void> setDailyWellnessReminder({
    required int id,
    required String title,
    required String body,
    required bool enabled,
    required int hour,
  }) async {
    await _plugin.cancel(id);
    if (!enabled) return;
    final now = DateTime.now();
    var time = DateTime(now.year, now.month, now.day, hour);
    if (!time.isAfter(now)) time = time.add(const Duration(days: 1));
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'wellness_reminders',
            'Wellness reminders',
            importance: Importance.defaultImportance,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> restoreWellnessReminders(AppSettings settings) async {
    await setDailyWellnessReminder(
      id: waterReminderId,
      title: 'Water reminder',
      body: 'Time for a glass of water.',
      enabled: settings.waterReminderEnabled,
      hour: settings.waterReminderHour,
    );
    await setDailyWellnessReminder(
      id: sleepReminderId,
      title: 'Sleep reminder',
      body: 'Start your wind-down routine.',
      enabled: settings.sleepReminderEnabled,
      hour: settings.sleepReminderHour,
    );
  }
}
