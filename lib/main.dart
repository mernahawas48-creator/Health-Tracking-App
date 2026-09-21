import 'package:flutter/material.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/medication_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Notification setup must never prevent the health dashboard from opening.
  try {
    await MedicationNotificationService.instance.initialize();
  } catch (_) {
    // The user can still use the app if a device temporarily rejects alerts.
  }
  final settingsController = await AppSettingsController.load();
  runApp(HealthApp(settingsController: settingsController));
}
