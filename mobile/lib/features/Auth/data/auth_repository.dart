import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import 'google_login_result.dart';
import 'google_sign_in_service.dart';
import 'user_model.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  final _googleSignIn = GoogleSignInService();

  // Shortcut so we don't write _apiClient.dio everywhere
  Dio get _dio => _apiClient.dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return await _saveSessionAndGetUser(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Emails a 6-digit code. Returns how many seconds must pass before the next send.
  Future<int> sendEmailCode(String email) async {
    try {
      final res = await _dio.post(
        '/auth/email-verification/send',
        data: {'email': email},
      );
      return res.data['data']['cooldownSeconds'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Checks the code and returns the proof that register requires.
  Future<String> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/email-verification/verify',
        data: {'email': email, 'code': code},
      );
      return res.data['data']['emailProof'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserModel> register({
    required String firstName,
    String? lastName,
    String? username,
    required String email,
    required String emailProof,
    required String password,
    required String universityId,
    required String collegeId,
    required String courseId,
    required int currentSemester,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          // optional fields: send only when the user actually typed something
          if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
          if (username != null && username.isNotEmpty) 'username': username,
          'email': email,
          'emailProof': emailProof,
          'password': password,
          'universityId': universityId,
          'collegeId': collegeId,
          'courseId': courseId,
          'currentSemester': currentSemester,
        },
      );
      return await _saveSessionAndGetUser(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Null when the user closes Google's account picker.
  Future<String?> getGoogleIdToken() => _googleSignIn.getIdToken();

  /// Logs in when this Google account has an account here (tokens are saved),
  /// otherwise says that it still has to sign up.
  Future<GoogleLoginResult> loginWithGoogle(String idToken) async {
    try {
      final res = await _dio.post('/auth/google', data: {'idToken': idToken});
      final data = res.data['data'] as Map<String, dynamic>;
      if (data['needsSignup'] == true) {
        return GoogleLoginResult.needsSignup(
          GoogleProfile.fromJson(data['profile'] as Map<String, dynamic>),
        );
      }
      return GoogleLoginResult.loggedIn(await _saveSessionAndGetUser(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Name and email come from the Google token; only the academic details are sent.
  Future<UserModel> registerWithGoogle({
    required String idToken,
    required String universityId,
    required String collegeId,
    required String courseId,
    required int currentSemester,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/google/register',
        data: {
          'idToken': idToken,
          'universityId': universityId,
          'collegeId': collegeId,
          'courseId': courseId,
          'currentSemester': currentSemester,
        },
      );
      return await _saveSessionAndGetUser(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Emails a reset code (the backend answers the same for unknown emails).
  /// Returns how many seconds must pass before the next send.
  Future<int> sendPasswordResetCode(String email) async {
    try {
      final res = await _dio.post(
        '/auth/forgot-password/send',
        data: {'email': email},
      );
      return res.data['data']['cooldownSeconds'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Checks the code and returns the proof that the reset step requires.
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/forgot-password/verify',
        data: {'email': email, 'code': code},
      );
      return res.data['data']['resetProof'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String resetProof,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/forgot-password/reset',
        data: {
          'email': email,
          'resetProof': resetProof,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Other devices are logged out by the backend; this one gets fresh tokens.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      final tokens = res.data['data']['tokens'];
      await _tokenStorage.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Used when the app starts: tokens are saved, so who is the user?
  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get('/auth/me');
      return UserModel.fromJson(res.data['data']['user']);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Quick local check: do we even have a saved login?
  Future<bool> hasSavedSession() async =>
      await _tokenStorage.readRefreshToken() != null;

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException {
      // Even if the server call fails, the user must still be logged out locally
    } finally {
      await _tokenStorage.clear();
      await _googleSignIn.signOut();
    }
  }

  // Login and register both return { user, tokens }: same handling for both
  Future<UserModel> _saveSessionAndGetUser(Map<String, dynamic> data) async {
    final tokens = data['tokens'];
    await _tokenStorage.saveTokens(
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user']);
  }
}
