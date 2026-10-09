import '../models/paged.dart';
import '../models/post.dart';
import '../models/resource.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

class BookmarksRepository {
  BookmarksRepository(this._api);

  final ApiClient _api;

  Future<void> setPostBookmarked(String postId, bool bookmarked) =>
      guardApi(() => bookmarked
          ? _api.dio.post('/bookmarks/posts/$postId')
          : _api.dio.delete('/bookmarks/posts/$postId'));

  Future<void> setResourceBookmarked(String resourceId, bool bookmarked) =>
      guardApi(() => bookmarked
          ? _api.dio.post('/bookmarks/resources/$resourceId')
          : _api.dio.delete('/bookmarks/resources/$resourceId'));

  Future<PageResult<Resource>> savedResources({int page = 1, int limit = 20}) =>
      guardApi(() async {
        final res = await _api.dio.get('/bookmarks/resources',
            queryParameters: {'page': page, 'limit': limit});
        return PageResult.fromJson(
          res.data['data']['resources'] as List,
          res.data['meta'] as Map<String, dynamic>,
          Resource.fromJson,
        );
      });

  Future<PageResult<Post>> savedPosts({int page = 1, int limit = 20}) =>
      guardApi(() async {
        final res = await _api.dio.get('/bookmarks/posts',
            queryParameters: {'page': page, 'limit': limit});
        return PageResult.fromJson(
          res.data['data']['posts'] as List,
          res.data['meta'] as Map<String, dynamic>,
          Post.fromJson,
        );
      });
}
