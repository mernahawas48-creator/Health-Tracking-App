import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/services/account_firestore.dart';
import 'package:meditrack/services/habit_streak_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App Check for development/testing on Android emulator/device
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
  );

  // Dependency Injection
  setupDependencies();
  HabitStreakService.account = getIt<AccountFirestore>();

  // Notification setup must never prevent the health dashboard from opening.
  try {
    await MedicationNotificationService.instance.initialize();
  } catch (_) {
    // The user can still use the app if a device temporarily rejects alerts.
  }

  final settingsController = await AppSettingsController.load(
    profiles: getIt(),
  );

  await MedicationNotificationService.instance.restoreWellnessReminders(
    settingsController.settings,
  );

  runApp(HealthApp(settingsController: settingsController));
}
