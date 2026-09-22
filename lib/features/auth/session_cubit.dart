import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/services/local_session_service.dart';

enum SessionStatus { loading, onboarding, signedOut, signedIn, failure }

class SessionCubit extends Cubit<SessionStatus> {
  SessionCubit(this._session) : super(SessionStatus.loading);

  final LocalSessionService _session;

  Future<void> restore() async {
    emit(SessionStatus.loading);
    try {
      final values = await Future.wait([
        _session.hasCompletedOnboarding(),
        _session.hasSession(),
      ]);
      emit(
        values[1]
            ? SessionStatus.signedIn
            : values[0]
            ? SessionStatus.signedOut
            : SessionStatus.onboarding,
      );
    } catch (_) {
      emit(SessionStatus.failure);
    }
  }

  Future<bool> completeOnboarding() async {
    try {
      await _session.finishOnboarding();
      emit(SessionStatus.signedOut);
      return true;
    } catch (_) {
      emit(SessionStatus.failure);
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      await _session.startSession();
      emit(SessionStatus.signedIn);
      return true;
    } catch (_) {
      emit(SessionStatus.failure);
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _session.endSession();
      emit(SessionStatus.signedOut);
      return true;
    } catch (_) {
      emit(SessionStatus.failure);
      return false;
    }
  }
}
