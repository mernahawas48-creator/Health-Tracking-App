import 'package:flutter/material.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/services/app_settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = await AppSettingsController.load();
  runApp(HealthApp(settingsController: settingsController));
}
