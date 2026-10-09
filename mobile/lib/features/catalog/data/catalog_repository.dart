import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  // Answers kept for the app session, so a screen that asks for the same list
  // again gets it instantly (a failed request is dropped so it can be retried)
  final _cache = <String, Future<List<dynamic>>>{};

  /// Delhi University is the default choice at sign-up.
  static University? defaultUniversity(List<University> universities) {
    for (final u in universities) {
      if (u.shortName.toUpperCase() == 'DU') return u;
    }
    for (final u in universities) {
      if (u.name.toLowerCase().contains('delhi')) return u;
    }
    return null;
  }

  /// Fetches the universities and the default one's colleges and courses in
  /// the background, so the sign-up screen opens with them already there.
  /// Best effort: errors are ignored.
  Future<void> warmUp() async {
    try {
      final default_ = defaultUniversity(await getUniversities());
      if (default_ == null) return;
      await Future.wait([getColleges(default_.id), getCourses(default_.id)]);
    } catch (_) {}
  }

  Future<List<University>> getUniversities() =>
      _getList('/universities', 'universities', University.fromJson);

  Future<List<College>> getColleges(String universityId) => _getList(
    '/colleges',
    'colleges',
    College.fromJson,
    query: {'universityId': universityId},
  );

  Future<List<Course>> getCourses(String universityId) => _getList(
    '/courses',
    'courses',
    Course.fromJson,
    query: {'universityId': universityId},
  );

  // One helper for all three: fetch, pull the list out, convert each item
  Future<List<T>> _getList<T>(
    String path,
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? query,
  }) async {
    final cacheKey = '$path?$query';
    final future = _cache.putIfAbsent(
      cacheKey,
      () => _fetchList<T>(path, key, fromJson, query),
    );
    try {
      return (await future).cast<T>();
    } catch (_) {
      _cache.remove(cacheKey);
      rethrow;
    }
  }

  Future<List<T>> _fetchList<T>(
    String path,
    String key,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? query,
  ) async {
    try {
      final res = await _apiClient.dio.get(path, queryParameters: query);
      final items = res.data['data'][key] as List;
      return items.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
