import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();

  // Notification setup must never prevent the health dashboard from opening.
  try {
    await MedicationNotificationService.instance.initialize();
  } catch (_) {
    // The user can still use the app if a device temporarily rejects alerts.
  }

  final settingsController = await AppSettingsController.load();

  await MedicationNotificationService.instance.restoreWellnessReminders(
    settingsController.settings,
  );

  runApp(HealthApp(settingsController: settingsController));
}
