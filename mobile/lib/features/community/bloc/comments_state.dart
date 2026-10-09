import 'package:equatable/equatable.dart';
import '../../../core/models/post.dart';

class CommentsState extends Equatable {
  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.hasMore = false,
    this.nextCursor,
    this.delta = 0, // comments added minus removed since the sheet opened
    this.error,
  });

  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final bool hasMore;
  final String? nextCursor;
  final int delta;
  final String? error;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    bool? hasMore,
    String? nextCursor,
    int? delta,
    String? error,
    bool clearError = false,
  }) =>
      CommentsState(
        comments: comments ?? this.comments,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isSending: isSending ?? this.isSending,
        hasMore: hasMore ?? this.hasMore,
        nextCursor: nextCursor ?? this.nextCursor,
        delta: delta ?? this.delta,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [
        comments, isLoading, isLoadingMore, isSending, hasMore, nextCursor,
        delta, error,
      ];
}
