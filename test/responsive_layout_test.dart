import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/features/ai_assistant_page.dart';
import 'package:meditrack/features/auth/login/login_page.dart';
import 'package:meditrack/features/auth/signup/signup_page.dart';
import 'package:meditrack/features/help_page.dart';
import 'package:meditrack/features/medications/medications_page.dart';
import 'package:meditrack/features/notification_center_page.dart';
import 'package:meditrack/features/nutrition_page.dart';
import 'package:meditrack/features/onboarding.dart';
import 'package:meditrack/features/privacy_page.dart';
import 'package:meditrack/features/profile_page.dart';
import 'package:meditrack/features/settings_page.dart';
import 'package:meditrack/features/sleep_tracker_page.dart';
import 'package:meditrack/features/water_tracker_page.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in [320.0, 390.0, 800.0]) {
    for (final name in [
      'Home',
      'Onboarding',
      'Login',
      'Signup',
      'Medications',
      'Nutrition',
      'Water',
      'Sleep',
      'Profile',
      'Settings',
      'Goals',
      'Notifications',
      'AI Assistant',
      'Help',
      'Privacy',
    ]) {
      testWidgets('$name fits ${width.toInt()} px', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        SharedPreferences.setMockInitialValues({
          'onboarding_complete': true,
          'local_signed_in': true,
        });
        setupDependencies();
        final settings = await AppSettingsController.load();
        await tester.pumpWidget(HealthApp(settingsController: settings));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Home at $width px');
        if (name == 'Home') return;

        final pages = <String, WidgetBuilder>{
          'Onboarding': (_) => const OnboardingPage(),
          'Login': (_) => const LoginPage(),
          'Signup': (_) => const SignupPage(),
          'Medications': (_) => const MedicationsPage(),
          'Nutrition': (_) => const NutritionPage(calorieGoal: 2000),
          'Water': (_) => const WaterTrackerPage(goalMl: 2000),
          'Sleep': (_) =>
              const SleepTrackerPage(initialSleepMinutes: 0, goalMinutes: 480),
          'Profile': (_) =>
              ProfilePage(initialName: 'User', onNameChanged: (_) {}),
          'Settings': (_) => SettingsPage(controller: settings),
          'Notifications': (_) => const NotificationCenterPage(),
          'AI Assistant': (_) => const AiAssistantPage(),
          'Help': (_) => const HelpPage(),
          'Privacy': (_) => const PrivacyPage(),
        };
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .push<void>(
              MaterialPageRoute(
                builder: name == 'Goals' ? pages['Settings']! : pages[name]!,
              ),
            );
        await tester.pumpAndSettle();
        if (name == 'Goals') {
          await tester.tap(find.byIcon(Icons.flag_outlined));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: '$name at $width px');
      });
    }
  }

  testWidgets('Signup scrolls above a small-phone keyboard', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'local_signed_in': true,
    });
    setupDependencies();
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(HealthApp(settingsController: settings));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push<void>(MaterialPageRoute(builder: (_) => const SignupPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Sign up').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
