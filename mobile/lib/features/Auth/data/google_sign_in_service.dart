import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/google_config.dart';

/// Opens Google's account picker and hands back the ID token the backend checks.
class GoogleSignInService {
  bool _isInitialized = false;

  /// Null when the user closes the picker without choosing an account.
  Future<String?> getIdToken() async {
    if (!isGoogleSignInConfigured) {
      throw const ApiException('Google sign-in is not set up in this build.');
    }
    if (!_isInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
      );
      _isInitialized = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const ApiException(
          'Google did not return a sign-in token. Please try again.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw ApiException(
        'Google sign-in failed (${e.code.name}). Please try again.',
      );
    }
  }

  /// So the next sign-in shows the account picker again.
  Future<void> signOut() async {
    if (!_isInitialized) return;
    try {
      await GoogleSignIn.instance.signOut();
    } on GoogleSignInException {
      // Nothing to do: the app session is cleared either way
    }
  }
}
