/// What the user typed in signup step 1. Step 1 hands it to step 2,
/// which adds the academic details and sends everything to the backend.
class SignupDraft {
  const SignupDraft({
    required this.firstName,
    this.lastName,
    this.username,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String? lastName; // null when left empty (backend allows that)
  final String? username; // null -> backend generates one
  final String email;
  final String password;
}
