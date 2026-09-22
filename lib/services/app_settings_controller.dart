import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._(this._settings, this._profiles);

  static const _storageKey = 'app_settings_device_v2';
  AppSettings _settings;
  final UserProfileRepository? _profiles;
  String? _uid;

  AppSettings get settings => _settings;
  String? get uid => _uid;

  static Future<AppSettingsController> load({
    UserProfileRepository? profiles,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    // Never import unowned legacy app_settings_v1 health/profile values.
    if (value == null)
      return AppSettingsController._(const AppSettings(), profiles);

    try {
      final device = AppSettings.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
      return AppSettingsController._(
        AppSettings.withAccount(device, null),
        profiles,
      );
    } catch (_) {
      return AppSettingsController._(const AppSettings(), profiles);
    }
  }

  Future<void> loadAccount(String uid) async {
    clearAccount();
    final account = await _profiles?.load(uid);
    final prefs = await SharedPreferences.getInstance();
    final image = prefs.getString('profile_image_$uid');
    _settings = AppSettings.withAccount(_settings, account, imagePath: image);
    _uid = uid;
    notifyListeners();
  }

  void clearAccount() {
    _uid = null;
    _settings = AppSettings.withAccount(_settings, null);
    notifyListeners();
  }

  Future<void> update(AppSettings updatedSettings) async {
    final owner = _uid;
    if (owner != null && _profiles != null) {
      await _profiles.save(owner, updatedSettings.toAccountJson());
      final preferences = await SharedPreferences.getInstance();
      if (updatedSettings.profileImagePath != null) {
        await preferences.setString(
          'profile_image_$owner',
          updatedSettings.profileImagePath!,
        );
      }
    }
    _settings = updatedSettings;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(_settings.toDeviceJson()),
    );
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
