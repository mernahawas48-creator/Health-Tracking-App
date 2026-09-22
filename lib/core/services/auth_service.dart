import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================================
  // SIGN UP
  // ==========================================================

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ==========================================================
  // SEND VERIFICATION EMAIL
  // ==========================================================

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ==========================================================
  // CHECK EMAIL VERIFICATION
  // ==========================================================

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();

    final user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  User? get currentUser => _auth.currentUser;
}