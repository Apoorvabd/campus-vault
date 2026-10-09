import 'package:dio/dio.dart';
import '../models/paged.dart';
import '../models/post.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

/// Result of like/unlike: the new state and total count from the server.
class LikeResult {
  const LikeResult({required this.liked, required this.count});
  final bool liked;
  final int count;
}

class PostsRepository {
  PostsRepository(this._api);

  final ApiClient _api;

  Future<CursorResult<Post>> list({
    String? search,
    String? authorId,
    String? courseId,
    String? cursor,
    int limit = 20,
  }) =>
      guardApi(() async {
        final res = await _api.dio.get('/posts', queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (authorId != null) 'authorId': authorId,
          if (courseId != null) 'courseId': courseId,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        });
        return CursorResult.fromJson(
          res.data['data']['posts'] as List,
          res.data['meta'] as Map<String, dynamic>,
          Post.fromJson,
        );
      });

  Future<Post> create({
    required String title,
    required String content,
    String? coverImagePath,
  }) =>
      guardApi(() async {
        final form = FormData.fromMap({
          'title': title,
          'content': content,
          if (coverImagePath != null)
            'coverImage': await multipartFromPath(coverImagePath),
        });
        final res = await _api.dio.post('/posts', data: form);
        return Post.fromJson(res.data['data']['post']);
      });

  Future<void> delete(String postId) =>
      guardApi(() => _api.dio.delete('/posts/$postId'));

  Future<LikeResult> like(String postId) => guardApi(() async {
        final res = await _api.dio.post('/posts/$postId/like');
        return LikeResult(
          liked: res.data['data']['liked'] as bool,
          count: (res.data['data']['likesCount'] as num).toInt(),
        );
      });

  Future<LikeResult> unlike(String postId) => guardApi(() async {
        final res = await _api.dio.delete('/posts/$postId/like');
        return LikeResult(
          liked: res.data['data']['liked'] as bool,
          count: (res.data['data']['likesCount'] as num).toInt(),
        );
      });

  Future<CursorResult<Comment>> comments(
    String postId, {
    String? cursor,
    int limit = 20,
  }) =>
      guardApi(() async {
        final res = await _api.dio.get('/posts/$postId/comments',
            queryParameters: {if (cursor != null) 'cursor': cursor, 'limit': limit});
        return CursorResult.fromJson(
          res.data['data']['comments'] as List,
          res.data['meta'] as Map<String, dynamic>,
          Comment.fromJson,
        );
      });

  Future<Comment> addComment(String postId, String content) =>
      guardApi(() async {
        final res = await _api.dio
            .post('/posts/$postId/comments', data: {'content': content});
        return Comment.fromJson(res.data['data']['comment']);
      });

  Future<void> deleteComment(String postId, String commentId) =>
      guardApi(() => _api.dio.delete('/posts/$postId/comments/$commentId'));
}
