import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, ApiClient apiClient) : super(const AuthInitial()) {
    // "When this event arrives, run this method"
    on<AuthStarted>(_onStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);

    // ApiClient announces "refresh failed"; turn that into an event on ourselves
    _sessionSub = apiClient.onSessionExpired.listen(
      (_) => add(const SessionExpired()),
    );
  }

  final AuthRepository _repository;

  /// True right after a new account was created (not on login), so the app
  /// can show the subjects form once before Home.
  bool justRegistered = false;
  late final StreamSubscription<void> _sessionSub;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // No saved login: skip the network and go to login
    if (!await _repository.hasSavedSession()) {
      emit(const Unauthenticated());
      return;
    }
    try {
      final user = await _repository.getMe();
      emit(Authenticated(user));
    } catch (_) {
      // Any failure here means we cannot trust the saved session
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        password: event.password,
        universityId: event.universityId,
        collegeId: event.collegeId,
        courseId: event.courseId,
        currentSemester: event.currentSemester,
      );
      justRegistered = true;
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const Unauthenticated());
  }

  void _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) {
    emit(const Unauthenticated());
  }

  // Stop listening when the Bloc is destroyed, otherwise it leaks
  @override
  Future<void> close() {
    _sessionSub.cancel();
    return super.close();
  }
}
