import 'package:equatable/equatable.dart';
import '../data/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Before we know anything (app just launched). Show the splash or landing screen.
class AuthInitial extends AuthState {
  const AuthInitial();
}

// A request is in progress. Show a spinner and disable the button.
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Logged in. Carries the user so any screen can read it.
class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

// Not logged in. Show the landing or login screen.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// Login or register failed. Carries the message to show.
class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
