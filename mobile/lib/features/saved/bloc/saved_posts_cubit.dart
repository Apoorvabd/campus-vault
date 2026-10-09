import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/network/api_exception.dart';
import 'saved_list_state.dart';

/// Bookmarked posts (second tab of the Saved screen).
class SavedPostsCubit extends Cubit<SavedListState<Post>> {
  SavedPostsCubit(this._bookmarks, this._posts) : super(const SavedListState());

  final BookmarksRepository _bookmarks;
  final PostsRepository _posts;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearLoadError: true));
    try {
      final result = await _bookmarks.savedPosts(page: 1);
      if (isClosed) return;
      emit(
        SavedListState(
          items: _markSaved(result.items),
          total: result.total,
          page: result.page,
          hasMore: result.hasMore,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, loadError: e.message));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result = await _bookmarks.savedPosts(page: state.page + 1);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: [...state.items, ..._markSaved(result.items)],
          total: result.total,
          page: result.page,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: false, actionError: e.message));
    }
  }

  /// Un-saves a post: removed right away, put back if the request fails.
  Future<void> unsave(Post post) async {
    final before = state;
    emit(
      state.copyWith(
        items: state.items.where((p) => p.id != post.id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      ),
    );
    try {
      await _bookmarks.setPostBookmarked(post.id, false);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(before.copyWith(actionError: e.message));
    }
  }

  /// Likes / unlikes with an instant update, rolled back if it fails.
  Future<void> toggleLike(Post post) async {
    final wasLiked = post.isLiked;
    _replace(
      post.copyWith(
        isLiked: !wasLiked,
        likeCount: post.likeCount + (wasLiked ? -1 : 1),
      ),
    );
    try {
      final result = wasLiked
          ? await _posts.unlike(post.id)
          : await _posts.like(post.id);
      if (isClosed) return;
      // Use the server's numbers as the truth
      _replace(post.copyWith(isLiked: result.liked, likeCount: result.count));
    } on ApiException catch (e) {
      if (isClosed) return;
      _replace(post);
      emit(state.copyWith(actionError: e.message));
    }
  }

  void _replace(Post updated) => emit(
    state.copyWith(
      items: [for (final p in state.items) p.id == updated.id ? updated : p],
    ),
  );

  List<Post> _markSaved(List<Post> items) =>
      items.map((p) => p.copyWith(isBookmarked: true)).toList();
}
