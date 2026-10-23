/// What the user gave in signup step 1 (or Google). Step 1 hands it to step 2,
/// which adds the academic details and sends everything to the backend.
///
/// Two kinds: an email signup carries a password and the proof from the email
/// OTP check; a Google signup carries the Google ID token instead, and the
/// backend takes the name and email from that token.
class SignupDraft {
  const SignupDraft({
    required this.firstName,
    this.lastName,
    this.username,
    required this.email,
    required String this.emailProof,
    required String this.password,
  }) : googleIdToken = null;

  const SignupDraft.google({
    required this.firstName,
    this.lastName,
    required this.email,
    required String this.googleIdToken,
  }) : username = null,
       emailProof = null,
       password = null;

  final String firstName;
  final String? lastName; // null when left empty (backend allows that)
  final String? username; // null -> backend generates one
  final String email;
  final String? emailProof; // from the email OTP check; register needs it
  final String? password;
  final String? googleIdToken;

  bool get isGoogle => googleIdToken != null;
}
