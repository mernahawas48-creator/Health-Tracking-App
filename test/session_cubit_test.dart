import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/local_session_service.dart';
import 'package:meditrack/services/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryProfiles extends UserProfileRepository {
  final records = <String, Map<String, dynamic>>{};
  @override
  Future<Map<String, dynamic>?> load(String uid) async => records[uid];
  @override
  Future<void> save(String uid, Map<String, dynamic> fields) async {
    records[uid] = {...?records[uid], ...fields};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({'onboarding_complete': true}),
  );

  test(
    'Firebase identity controls restore, account switch and logout',
    () async {
      final profiles = MemoryProfiles();
      final settings = await AppSettingsController.load(profiles: profiles);
      String? uid;
      final session = SessionCubit(
        LocalSessionService(),
        currentUid: () => uid,
        settings: settings,
        signOutExistingAuth: () async => uid = null,
      );
      addTearDown(session.close);

      await session.restore();
      expect(session.state, SessionStatus.signedOut);
      uid = 'A';
      await session.restore();
      expect(session.state, SessionStatus.profileSetup);
      expect(settings.settings.displayName, 'User Name');
      await settings.update(
        settings.settings.copyWith(
          displayName: 'Alice',
          profileSetupComplete: true,
          healthGoals: ['Build Muscle'],
          waterGoalMl: 2500,
        ),
      );
      expect(await session.signIn(), isTrue);
      expect(session.activeUid, 'A');
      expect(session.state, SessionStatus.signedIn);

      expect(await session.signOut(), isTrue);
      expect(session.state, SessionStatus.signedOut);
      expect(settings.settings.displayName, 'User Name');
      expect(settings.settings.healthGoals, isEmpty);
      expect(settings.settings.waterGoalMl, 2000);
      expect(profiles.records['A']?['displayName'], 'Alice');

      uid = 'B';
      await session.restore();
      expect(session.state, SessionStatus.profileSetup);
      expect(settings.settings.displayName, 'User Name');
      await settings.update(
        settings.settings.copyWith(
          displayName: 'Bob',
          profileSetupComplete: true,
        ),
      );
      await session.signIn();
      expect(settings.settings.displayName, 'Bob');
      await session.signOut();

      uid = 'A';
      await session.restore();
      expect(session.state, SessionStatus.signedIn);
      expect(settings.settings.displayName, 'Alice');
      expect(settings.settings.healthGoals, ['Build Muscle']);
      expect(settings.settings.waterGoalMl, 2500);
    },
  );

  test('unowned legacy profile is never assigned to an account', () async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'app_settings_v1': '{"displayName":"Legacy","profileSetupComplete":true}',
      'local_signed_in': true,
    });
    final settings = await AppSettingsController.load(
      profiles: MemoryProfiles(),
    );
    final session = SessionCubit(
      LocalSessionService(),
      currentUid: () => 'new',
      settings: settings,
    );
    addTearDown(session.close);
    await session.restore();
    expect(session.state, SessionStatus.profileSetup);
    expect(settings.settings.displayName, 'User Name');
    expect(settings.settings.profileSetupComplete, isFalse);
  });
}
