import 'dart:async';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient(this._tokenStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          // Long enough for a cold-starting host (Render's free tier can take
          // ~30-60s to wake up) instead of failing the first request
          receiveTimeout: const Duration(seconds: 45),
          headers: {'Accept': 'application/json'},
        ),
      ),
      // Refresh call ke liye alag Dio, bina interceptor ke, warna loop ban jayega
      _refreshDio = Dio(BaseOptions(baseUrl: apiBaseUrl)),
      // Own client for the wake-up ping: very patient, no auth, no interceptors
      _wakeDio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 90),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _attachToken, onError: _handleError),
    );
  }

  final Dio dio;
  final Dio _refreshDio;
  final Dio _wakeDio;
  DateTime? _lastWake;
  final TokenStorage _tokenStorage;

  Future<String?>? _refreshing;
  final _sessionExpired = StreamController<void>.broadcast();

  /// Refresh bhi fail ho gaya -> AuthBloc ise sunkar user ko login par bhejega
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  /// Fire-and-forget request that wakes a sleeping backend. Call it when the
  /// app shows its landing screen: the user spends a few seconds there while
  /// the server starts, so their first real request (login / register) finds
  /// it awake. Never waits, never shows an error, and runs at most once every
  /// few minutes.
  void wakeServer() {
    final last = _lastWake;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 5)) {
      return;
    }
    _lastWake = DateTime.now();
    _wakeDio
        .get('/health')
        .then(
          (_) {},
          onError: (_) {
            // Failed: let the next call try again
            _lastWake = null;
          },
        );
  }

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;

    // Login ka 401 ("Invalid Credentials") refresh trigger nahi karna chahiye
    if (!isUnauthorized ||
        req.extra['retried'] == true ||
        _isAuthPath(req.path)) {
      return handler.next(err);
    }

    // Ek saath kai requests 401 khayein to refresh sirf ek baar chale
    _refreshing ??= _refreshAccessToken().whenComplete(
      () => _refreshing = null,
    );
    final newToken = await _refreshing;

    if (newToken == null) {
      _sessionExpired.add(null);
      return handler.next(err);
    }

    req.headers['Authorization'] = 'Bearer $newToken';
    req.extra['retried'] = true;
    try {
      handler.resolve(await dio.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final res = await _refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      final tokens = res.data['data']['tokens'];
      await _tokenStorage.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );
      return tokens['accessToken'] as String;
    } on DioException {
      await _tokenStorage.clear();
      return null;
    }
  }

  bool _isAuthPath(String path) =>
      path.startsWith('/auth/login') ||
      path.startsWith('/auth/register') ||
      path.startsWith('/auth/refresh-token');
}
