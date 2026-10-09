import 'package:dio/dio.dart';
import '../models/paged.dart';
import '../models/resource.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

class ResourcesRepository {
  ResourcesRepository(this._api);

  final ApiClient _api;

  /// Public list is always APPROVED resources. With [mine] true you get your
  /// own uploads in any status (use [status] to narrow it).
  Future<PageResult<Resource>> list({
    String? subjectId,
    String? courseId,
    int? semester,
    ResourceType? type,
    ResourceStatus? status,
    String? search,
    bool mine = false,
    bool sortByDownloads = false,
    int page = 1,
    int limit = 20,
  }) =>
      guardApi(() async {
        final res = await _api.dio.get('/resources', queryParameters: {
          if (subjectId != null) 'subjectId': subjectId,
          if (courseId != null) 'courseId': courseId,
          if (semester != null) 'semester': semester,
          if (type != null) 'resourceType': type.apiValue,
          if (status != null) 'status': status.apiValue,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (mine) 'mine': 'true',
          if (sortByDownloads) 'sort': 'downloads',
          'page': page,
          'limit': limit,
        });
        return PageResult.fromJson(
          res.data['data']['resources'] as List,
          res.data['meta'] as Map<String, dynamic>,
          Resource.fromJson,
        );
      });

  Future<Resource> get(String id) => guardApi(() async {
        final res = await _api.dio.get('/resources/$id');
        return Resource.fromJson(res.data['data']['resource']);
      });

  /// Creates a resource in PENDING status (an admin approves it later).
  /// HOSTED needs [filePath] (PDF/JPG/PNG, max 15 MB); EXTERNAL_LINK needs
  /// [externalUrl].
  Future<Resource> create({
    required String title,
    String? description,
    required ResourceType type,
    required String subjectId,
    required ResourceSource source,
    String? externalUrl,
    String? filePath,
  }) =>
      guardApi(() async {
        final form = FormData.fromMap({
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'resourceType': type.apiValue,
          'subjectId': subjectId,
          'sourceType': source.apiValue,
          if (source == ResourceSource.externalLink && externalUrl != null)
            'externalUrl': externalUrl,
          if (source == ResourceSource.hosted && filePath != null)
            'file': await multipartFromPath(filePath),
        });
        final res = await _api.dio.post('/resources', data: form);
        return Resource.fromJson(res.data['data']['resource']);
      });

  /// Call when the user opens/downloads a resource. Returns the new count.
  Future<int> recordDownload(String id) => guardApi(() async {
        final res = await _api.dio.post('/resources/$id/download');
        return (res.data['data']['downloadCount'] as num).toInt();
      });
}
