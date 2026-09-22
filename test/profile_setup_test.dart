import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/features/create_profile/create_profile_page.dart';
import 'package:meditrack/features/profile_page.dart';
import 'package:meditrack/models/health_goals.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/local_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('signup and Personal Details use one persisted goal catalog', () async {
    SharedPreferences.setMockInitialValues({});
    expect(
      HealthGoals.available,
      containsAll(['Build Muscle', 'Improve sleep']),
    );
    final controller = await AppSettingsController.load();
    await controller.update(
      controller.settings.copyWith(
        healthGoals: ['Build Muscle', 'Improve sleep'],
      ),
    );
    final restored = await AppSettingsController.load();
    expect(restored.settings.healthGoals, ['Build Muscle', 'Improve sleep']);
    await restored.update(
      restored.settings.copyWith(healthGoals: ['Stay active']),
    );
    expect((await AppSettingsController.load()).settings.healthGoals, [
      'Stay active',
    ]);
  });

  test('profile details survive settings reload', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = await AppSettingsController.load();
    final birthday = DateTime(2000, 5, 17);
    await controller.update(
      controller.settings.copyWith(
        displayName: 'Mira',
        profileSetupComplete: true,
        dateOfBirth: birthday,
        age: 26,
        gender: 'female',
        heightCm: 165,
        weightKg: 60,
        healthGoals: ['Stay Healthy'],
        profileImagePath: '/saved/profile_photo.jpg',
      ),
    );
    final restored = await AppSettingsController.load();
    expect(restored.settings.dateOfBirth, birthday);
    expect(restored.settings.age, 26);
    expect(restored.settings.gender, 'female');
    expect(restored.settings.healthGoals, ['Stay Healthy']);
    expect(restored.settings.profileImagePath, '/saved/profile_photo.jpg');
  });

  testWidgets('Finish saves profile, starts session, and opens Home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final settings = await AppSettingsController.load();
    final session = SessionCubit(LocalSessionService());
    addTearDown(session.close);

    await tester.pumpWidget(
      AppSettingsScope(
        controller: settings,
        child: BlocProvider.value(
          value: session,
          child: MaterialApp(
            initialRoute: '/profileview',
            routes: {
              '/profileview': (_) => const CreateProfilePage(),
              '/home': (_) => const Scaffold(body: Text('HOME')),
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Mira');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '165');
    await tester.enterText(find.byType(TextFormField).at(1), '60');
    await tester.ensureVisible(find.text('Build Muscle'));
    await tester.tap(find.text('Build Muscle'));
    await tester.ensureVisible(find.text('Finish'));
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(session.state, SessionStatus.signedIn);
    expect(settings.settings.displayName, 'Mira');
    expect(settings.settings.heightCm, 165);
    expect(settings.settings.weightKg, 60);
    expect(settings.settings.healthGoals, ['Build Muscle']);
    expect(settings.settings.profileSetupComplete, isTrue);
    expect(Navigator.of(tester.element(find.text('HOME'))).canPop(), isFalse);

    final restored = await AppSettingsController.load();
    expect(restored.settings.displayName, 'Mira');
    expect(restored.settings.heightCm, 165);
    expect(restored.settings.weightKg, 60);
    expect(restored.settings.healthGoals, ['Build Muscle']);
    expect(restored.settings.profileSetupComplete, isTrue);
    expect(await LocalSessionService.signedIn(), isTrue);
  });

  testWidgets('restored name appears on Home and Profile', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'local_signed_in': true,
    });
    setupDependencies();
    final settings = await AppSettingsController.load();
    await settings.update(
      settings.settings.copyWith(
        displayName: 'Mira',
        profileSetupComplete: true,
        healthGoals: ['Build Muscle'],
      ),
    );
    final restored = await AppSettingsController.load();
    await tester.pumpWidget(HealthApp(settingsController: restored));
    await tester.pumpAndSettle();
    expect(find.text('Mira'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_2_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Mira'), findsOneWidget);
    expect(find.text('Build Muscle'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal details'));
    await tester.pumpAndSettle();
    final selectedGoal = find.widgetWithText(CheckboxListTile, 'Build Muscle');
    expect(tester.widget<CheckboxListTile>(selectedGoal).value, isTrue);
  });
}
