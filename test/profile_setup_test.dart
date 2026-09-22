import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/features/create_profile/create_profile_page.dart';
import 'package:meditrack/models/health_goals.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/local_session_service.dart';
import 'package:meditrack/services/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeProfiles extends UserProfileRepository {
  final values = <String, Map<String, dynamic>>{};
  @override
  Future<Map<String, dynamic>?> load(String uid) async => values[uid];
  @override
  Future<void> save(String uid, Map<String, dynamic> fields) async =>
      values[uid] = {...?values[uid], ...fields};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('health goals use one catalog and persist under the UID', () async {
    SharedPreferences.setMockInitialValues({});
    expect(
      HealthGoals.available,
      containsAll(['Build Muscle', 'Improve sleep']),
    );
    final profiles = FakeProfiles();
    final controller = await AppSettingsController.load(profiles: profiles);
    await controller.loadAccount('A');
    await controller.update(
      controller.settings.copyWith(
        healthGoals: ['Build Muscle'],
        displayName: 'Mira',
        profileSetupComplete: true,
      ),
    );
    expect(profiles.values['A']?['healthGoals'], ['Build Muscle']);
    controller.clearAccount();
    await controller.loadAccount('B');
    expect(controller.settings.healthGoals, isEmpty);
    expect(controller.settings.displayName, 'User Name');
  });

  testWidgets('Finish saves a new account profile before Home', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final profiles = FakeProfiles();
    final settings = await AppSettingsController.load(profiles: profiles);
    final session = SessionCubit(
      LocalSessionService(),
      currentUid: () => 'new-uid',
      settings: settings,
    );
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
    expect(profiles.values['new-uid']?['displayName'], 'Mira');
    expect(profiles.values['new-uid']?['healthGoals'], ['Build Muscle']);
    expect(profiles.values['new-uid']?['heightCm'], 165);
  });
}
