import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  static Future<void>? _googleInitialization;

  // ==========================================================
  // GOOGLE SIGN IN
  // ==========================================================

  Future<UserCredential> signInWithGoogle() async {
    final google = GoogleSignIn.instance;

    try {
      await (_googleInitialization ??= google.initialize());
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }

    final account = await google.authenticate();

    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw StateError('Google did not provide an ID token.');
    }

    return _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  // ==========================================================
  // SIGN UP
  // ==========================================================

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
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
      email: email.trim(),
      password: password,
    );
  }

  // ==========================================================
  // SEND VERIFICATION EMAIL
  // Not required for login, but kept for compatibility
  // ==========================================================

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ==========================================================
  // CHECK EMAIL VERIFICATION
  // Not required for login
  // ==========================================================

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();

    final user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await _auth.signOut();

    if (_googleInitialization != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Firebase has already been signed out.
      }
    }
  }

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
