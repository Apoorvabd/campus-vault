import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import 'user_model.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

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

  Future<UserModel> register({
    required String firstName,
    String? lastName,
    String? username,
    required String email,
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
