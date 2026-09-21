import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/app_settings_controller.dart';

import 'routes.dart';

class HealthApp extends StatelessWidget {
  const HealthApp({super.key, required this.settingsController});

  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: settingsController,
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (context, _) {
          final settings = settingsController.settings;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: settings.isArabic ? 'متابعة الصحة' : 'Health Tracker',
            locale: Locale(settings.languageCode),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: _themeMode(settings.theme),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff00A1A9),
              ),
              scaffoldBackgroundColor: const Color(0xffF9F7FB),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff00A1A9),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: appRoutes,
          );
        },
      ),
    );
  }

  ThemeMode _themeMode(AppThemePreference value) {
    switch (value) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}
