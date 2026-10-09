import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/network/api_exception.dart';
import 'feed_state.dart';

/// Community feed: pages of posts plus like / bookmark / delete actions.
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._posts, this._bookmarks, this._myId)
      : super(const FeedState());

  final PostsRepository _posts;
  final BookmarksRepository _bookmarks;

  /// Returns the logged-in user's id (null while the profile is loading).
  final String? Function() _myId;

  // Bumped on every reload so a slow old response can't overwrite a new one
  int _generation = 0;

  /// First page. Used for the first load, pull-to-refresh and filter change.
  Future<void> load({bool? onlyMine}) async {
    final mine = onlyMine ?? state.onlyMine;
    final generation = ++_generation;
    emit(FeedState(
      posts: state.posts,
      onlyMine: mine,
      isLoading: true,
      noticeId: state.noticeId,
    ));
    try {
      final result = await _posts.list(authorId: mine ? _myId() : null);
      if (isClosed || generation != _generation) return;
      emit(FeedState(
        posts: result.items,
        hasMore: result.hasNextPage,
        nextCursor: result.nextCursor,
        onlyMine: mine,
        noticeId: state.noticeId,
      ));
    } on ApiException catch (e) {
      if (isClosed || generation != _generation) return;
      emit(FeedState(
        posts: state.posts,
        onlyMine: mine,
        error: e.message,
        noticeId: state.noticeId,
      ));
    }
  }

  /// Next page, called when the user scrolls near the bottom.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result = await _posts.list(
        authorId: state.onlyMine ? _myId() : null,
        cursor: state.nextCursor,
      );
      if (isClosed || generation != _generation) return;
      emit(FeedState(
        posts: [...state.posts, ...result.items],
        hasMore: result.hasNextPage,
        nextCursor: result.nextCursor,
        onlyMine: state.onlyMine,
        noticeId: state.noticeId,
      ));
    } on ApiException catch (e) {
      if (isClosed || generation != _generation) return;
      _notify(e.message, isLoadingMore: false);
    }
  }

  /// Like / unlike. The UI changes first; we roll back if the server fails.
  Future<void> toggleLike(Post post) async {
    final wasLiked = post.isLiked;
    _update(post.id, (p) => p.copyWith(
          isLiked: !wasLiked,
          likeCount: p.likeCount + (wasLiked ? -1 : 1),
        ));
    try {
      final result =
          wasLiked ? await _posts.unlike(post.id) : await _posts.like(post.id);
      if (isClosed) return;
      // Use the server's real values
      _update(post.id, (p) =>
          p.copyWith(isLiked: result.liked, likeCount: result.count));
    } on ApiException catch (e) {
      if (isClosed) return;
      _update(post.id, (p) => p.copyWith(
            isLiked: wasLiked,
            likeCount: p.likeCount + (wasLiked ? 1 : -1),
          ));
      _notify(e.message);
    }
  }

  /// Bookmark / unbookmark, same optimistic idea as [toggleLike].
  Future<void> toggleBookmark(Post post) async {
    final was = post.isBookmarked;
    _update(post.id, (p) => p.copyWith(
          isBookmarked: !was,
          bookmarkCount: p.bookmarkCount + (was ? -1 : 1),
        ));
    try {
      await _bookmarks.setPostBookmarked(post.id, !was);
    } on ApiException catch (e) {
      if (isClosed) return;
      _update(post.id, (p) => p.copyWith(
            isBookmarked: was,
            bookmarkCount: p.bookmarkCount + (was ? 1 : -1),
          ));
      _notify(e.message);
    }
  }

  Future<void> deletePost(Post post) async {
    try {
      await _posts.delete(post.id);
      if (isClosed) return;
      emit(state.copyWith(
        posts: state.posts.where((p) => p.id != post.id).toList(),
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      _notify(e.message);
    }
  }

  /// Comments were added/removed in the sheet; keep the card's count in sync.
  void changeCommentCount(String postId, int delta) {
    if (delta == 0) return;
    _update(postId, (p) =>
        p.copyWith(commentCount: (p.commentCount + delta).clamp(0, 1 << 30)));
  }

  void _update(String id, Post Function(Post) change) {
    emit(state.copyWith(
      posts: [for (final p in state.posts) p.id == id ? change(p) : p],
    ));
  }

  void _notify(String message, {bool? isLoadingMore}) => emit(state.copyWith(
        notice: message,
        noticeId: state.noticeId + 1,
        isLoadingMore: isLoadingMore,
      ));
}
