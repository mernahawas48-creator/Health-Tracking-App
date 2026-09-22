import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/services/local_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'restores onboarding, sign in, and sign out from local storage',
    () async {
      final cubit = SessionCubit(LocalSessionService());
      await cubit.restore();
      expect(cubit.state, SessionStatus.onboarding);

      expect(await cubit.completeOnboarding(), isTrue);
      expect(cubit.state, SessionStatus.signedOut);
      expect(await LocalSessionService.onboardingComplete(), isTrue);

      expect(await cubit.signIn(), isTrue);
      expect(cubit.state, SessionStatus.signedIn);
      expect(await LocalSessionService.signedIn(), isTrue);

      await cubit.restore();
      expect(cubit.state, SessionStatus.signedIn);

      expect(await cubit.signOut(), isTrue);
      expect(cubit.state, SessionStatus.signedOut);
      expect(await LocalSessionService.signedIn(), isFalse);
      await cubit.close();
    },
  );
}
