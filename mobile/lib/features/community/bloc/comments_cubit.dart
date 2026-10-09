import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/network/api_exception.dart';
import 'comments_state.dart';

/// Comments of one post (oldest first, loaded page by page).
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository, this.postId) : super(const CommentsState());

  final PostsRepository _repository;
  final String postId;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await _repository.comments(postId);
      if (isClosed) return;
      emit(state.copyWith(
        comments: result.items,
        isLoading: false,
        hasMore: result.hasNextPage,
        nextCursor: result.nextCursor,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final result =
          await _repository.comments(postId, cursor: state.nextCursor);
      if (isClosed) return;
      emit(state.copyWith(
        comments: [...state.comments, ...result.items],
        isLoadingMore: false,
        hasMore: result.hasNextPage,
        nextCursor: result.nextCursor,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: false, error: e.message));
    }
  }

  /// Returns true when the comment was posted (so the input can be cleared).
  Future<bool> add(String content) async {
    final text = content.trim();
    if (text.isEmpty || state.isSending) return false;
    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final comment = await _repository.addComment(postId, text);
      if (isClosed) return true;
      emit(state.copyWith(
        comments: [...state.comments, comment],
        isSending: false,
        delta: state.delta + 1,
      ));
      return true;
    } on ApiException catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(isSending: false, error: e.message));
      return false;
    }
  }

  Future<void> delete(Comment comment) async {
    try {
      await _repository.deleteComment(postId, comment.id);
      if (isClosed) return;
      emit(state.copyWith(
        comments: state.comments.where((c) => c.id != comment.id).toList(),
        delta: state.delta - 1,
        clearError: true,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: e.message));
    }
  }
}
