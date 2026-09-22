import 'package:shared_preferences/shared_preferences.dart';

class LocalSessionService {
  static const _onboardingKey = 'onboarding_complete';
  static const _signedInKey = 'local_signed_in';
  static Future<bool> onboardingComplete() async =>
      (await SharedPreferences.getInstance()).getBool(_onboardingKey) ?? false;
  static Future<bool> signedIn() async =>
      (await SharedPreferences.getInstance()).getBool(_signedInKey) ?? false;
  static Future<void> completeOnboarding() async =>
      (await SharedPreferences.getInstance()).setBool(_onboardingKey, true);
  static Future<void> signIn() async =>
      (await SharedPreferences.getInstance()).setBool(_signedInKey, true);
  static Future<void> signOut() async =>
      (await SharedPreferences.getInstance()).setBool(_signedInKey, false);

  Future<bool> hasCompletedOnboarding() => onboardingComplete();
  Future<bool> hasSession() => signedIn();
  Future<void> finishOnboarding() => completeOnboarding();
  Future<void> startSession() => signIn();
  Future<void> endSession() => signOut();
}
