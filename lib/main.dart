import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/core/di/injection.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dependency Injection
  setupDependencies();

  // Notifications
  try {
    await MedicationNotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }

  // Settings
  final settingsController = await AppSettingsController.load(
    profiles: getIt(),
  );

  try {
    await MedicationNotificationService.instance.restoreWellnessReminders(
      settingsController.settings,
    );
  } catch (e) {
    debugPrint('Reminder restore error: $e');
  }

  runApp(HealthApp(settingsController: settingsController));
}
