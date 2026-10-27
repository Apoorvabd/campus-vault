import 'user_model.dart';

/// Who Google says the user is, for an account that does not exist here yet.
class GoogleProfile {
  const GoogleProfile({
    required this.email,
    required this.firstName,
    this.lastName,
  });

  factory GoogleProfile.fromJson(Map<String, dynamic> json) => GoogleProfile(
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String?,
  );

  final String email;
  final String firstName;
  final String? lastName;
}

/// Either the user is logged in, or this Google account still has to sign up.
class GoogleLoginResult {
  const GoogleLoginResult.loggedIn(UserModel this.user) : signupProfile = null;

  const GoogleLoginResult.needsSignup(GoogleProfile this.signupProfile)
    : user = null;

  final UserModel? user;
  final GoogleProfile? signupProfile;
}
