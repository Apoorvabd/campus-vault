import 'package:equatable/equatable.dart';

// "sealed" means all events must be defined in this file,
// so Dart can check we handled every one of them.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// App just opened: is there a saved login?
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted({
    required this.firstName,
    this.lastName,
    this.username,
    required this.email,
    required this.password,
    required this.universityId,
    required this.collegeId,
    required this.courseId,
    required this.currentSemester,
  });

  final String firstName;
  final String? lastName;
  final String? username;
  final String email;
  final String password;
  final String universityId;
  final String collegeId;
  final String courseId;
  final int currentSemester;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    email,
    password,
    universityId,
    collegeId,
    courseId,
    currentSemester,
  ];
}

// User tapped Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// ApiClient reported that the refresh token also failed
class SessionExpired extends AuthEvent {
  const SessionExpired();
}
