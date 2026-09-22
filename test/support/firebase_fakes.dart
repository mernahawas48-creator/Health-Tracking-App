import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/services/user_profile_repository.dart';

class FakeUser implements User {
  @override
  String get uid => 'test-user';
  @override
  bool get emailVerified => true;
  @override
  List<UserInfo> get providerData => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService extends AuthService {
  final _user = FakeUser();
  @override
  User? get currentUser => _user;
  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  @override
  Future<void> logout() async {}
}

class FakeProfiles extends UserProfileRepository {
  @override
  Future<Map<String, dynamic>?> load(String uid) async => {
    'displayName': 'User',
    'profileSetupComplete': true,
    'healthGoals': <String>[],
  };
  @override
  Future<void> save(String uid, Map<String, dynamic> fields) async {}
}

void registerFirebaseFakes() {
  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerSingleton<AuthService>(FakeAuthService());
  }
  if (!getIt.isRegistered<UserProfileRepository>()) {
    getIt.registerSingleton<UserProfileRepository>(FakeProfiles());
  }
}
