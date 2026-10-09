import 'package:equatable/equatable.dart';
import '../../../core/models/post.dart';

class FeedState extends Equatable {
  const FeedState({
    this.posts = const [],
    this.isLoading = false, // first load / refresh
    this.isLoadingMore = false, // next page
    this.hasMore = false,
    this.nextCursor,
    this.onlyMine = false, // "My Posts" filter
    this.error, // load error, shown with a retry button
    this.notice, // one-off message (SnackBar), e.g. "like failed"
    this.noticeId = 0, // changes every time so the same text shows again
  });

  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final bool onlyMine;
  final String? error;
  final String? notice;
  final int noticeId;

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    bool? onlyMine,
    String? error,
    String? notice,
    int? noticeId,
    bool clearError = false,
  }) =>
      FeedState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        nextCursor: nextCursor ?? this.nextCursor,
        onlyMine: onlyMine ?? this.onlyMine,
        error: clearError ? null : (error ?? this.error),
        notice: notice ?? this.notice,
        noticeId: noticeId ?? this.noticeId,
      );

  @override
  List<Object?> get props => [
        posts, isLoading, isLoadingMore, hasMore, nextCursor, onlyMine,
        error, notice, noticeId,
      ];
}
