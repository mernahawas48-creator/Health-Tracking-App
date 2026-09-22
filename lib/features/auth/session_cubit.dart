import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';

import 'package:meditrack/services/local_session_service.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/services/medication_notification_service.dart';

enum SessionStatus {
  loading,
  onboarding,
  signedOut,
  profileSetup,
  signedIn,
  failure,
}

class SessionCubit extends Cubit<SessionStatus> {
  SessionCubit(
    this._session, {
    required String? Function() currentUid,
    required AppSettingsController settings,
    bool Function()? canUseAccount,
    Future<void> Function()? signOutExistingAuth,
  }) : _signOutExistingAuth = signOutExistingAuth,
       _currentUid = currentUid,
       _canUseAccount = canUseAccount,
       _settings = settings,
       super(SessionStatus.loading);

  final LocalSessionService _session;
  final Future<void> Function()? _signOutExistingAuth;
  final String? Function() _currentUid;
  final bool Function()? _canUseAccount;
  final AppSettingsController _settings;
  String? _activeUid;
  String? get activeUid => _activeUid;
  StreamSubscription<String?>? _subscription;

  void watch(Stream<String?> changes) {
    _subscription ??= changes.listen((uid) {
      if (uid == null && _activeUid != null) {
        _activeUid = null;
        _settings.clearAccount();
        MedicationNotificationService.instance.cancelMedicationReminders();
        emit(SessionStatus.signedOut);
      } else if (uid != null && _activeUid != null && uid != _activeUid) {
        _activeUid = null;
        _settings.clearAccount();
        restore();
      }
    });
  }

  Future<void> restore() async {
    emit(SessionStatus.loading);

    try {
      final uid = _currentUid();

      // No Firebase authenticated user
      if (uid == null || uid.isEmpty) {
        emit(SessionStatus.signedOut);
        return;
      }

      // Firebase user exists -> open the app
      emit(SessionStatus.signedIn);
    } catch (e) {
      // Authentication/session failure should not leave the app
      // stuck on the Retry screen.
      emit(SessionStatus.signedOut);
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
      final uid = _currentUid();
      if (uid == null || !(_canUseAccount?.call() ?? true)) return false;
      if (_settings.uid != uid) await _settings.loadAccount(uid);
      _activeUid = uid;
      emit(SessionStatus.signedIn);
      return true;
    } catch (_) {
      emit(SessionStatus.failure);
      return false;
    }
  }

  /// Returns null when Firebase has no account, otherwise its profile state.
  Future<bool?> prepareAccount() async {
    final uid = _currentUid();
    if (uid == null || !(_canUseAccount?.call() ?? true)) return null;
    await _settings.loadAccount(uid);
    return _settings.settings.profileSetupComplete;
  }

  Future<bool> signOut() async {
    try {
      await _signOutExistingAuth?.call();
      await _session.endSession();
      await MedicationNotificationService.instance.cancelMedicationReminders();
      _activeUid = null;
      _settings.clearAccount();
      emit(SessionStatus.signedOut);
      return true;
    } catch (_) {
      emit(SessionStatus.failure);
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
