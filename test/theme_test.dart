import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/features/home/home.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dark selection recolors the dashboard and survives reload', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'local_signed_in': true,
    });
    setupDependencies();
    final controller = await AppSettingsController.load();
    await tester.pumpWidget(HealthApp(settingsController: controller));
    await tester.pumpAndSettle();

    await controller.update(
      controller.settings.copyWith(theme: AppThemePreference.dark),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    final homeContext = tester.element(find.byType(HomePage));
    expect(Theme.of(homeContext).brightness, Brightness.dark);
    expect(
      Theme.of(homeContext).scaffoldBackgroundColor,
      AppTheme.dark().scaffoldBackgroundColor,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      AppTheme.dark().scaffoldBackgroundColor,
    );
    expect(
      AppTheme.dark().colorScheme.surface,
      isNot(AppTheme.light().colorScheme.surface),
    );
    await tester.tap(find.byIcon(Icons.local_pharmacy_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
      AppTheme.dark().scaffoldBackgroundColor,
    );
    expect(
      (await AppSettingsController.load()).settings.theme,
      AppThemePreference.dark,
    );
  });
}
