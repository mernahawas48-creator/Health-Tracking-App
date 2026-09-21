import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._(this._settings);

  static const _storageKey = 'app_settings_v1';
  AppSettings _settings;

  AppSettings get settings => _settings;

  static Future<AppSettingsController> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) return AppSettingsController._(const AppSettings());

    try {
      return AppSettingsController._(
        AppSettings.fromJson(jsonDecode(value) as Map<String, dynamic>),
      );
    } on FormatException {
      return AppSettingsController._(const AppSettings());
    }
  }

  Future<void> update(AppSettings updatedSettings) async {
    _settings = updatedSettings;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(_settings.toJson()));
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing above this widget.');
    return scope!.notifier!;
  }
}
