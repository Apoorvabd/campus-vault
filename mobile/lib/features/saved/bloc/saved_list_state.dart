import 'package:equatable/equatable.dart';

/// One tab of the Saved screen: a paginated list of bookmarked items.
class SavedListState<T> extends Equatable {
  const SavedListState({
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false, // first page or refresh
    this.isLoadingMore = false,
    this.loadError, // shown full-screen when the first load failed
    this.actionError, // one-shot message for a failed like / un-save
  });

  final List<T> items;
  final int total; // total saved on the server (for the header count)
  final int page; // last page loaded (0 = nothing yet)
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? loadError;
  final String? actionError;

  /// [actionError] is not copied, so it lasts for one state only.
  SavedListState<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? loadError,
    bool clearLoadError = false,
    String? actionError,
  }) {
    return SavedListState<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
    items,
    total,
    page,
    hasMore,
    isLoading,
    isLoadingMore,
    loadError,
    actionError,
  ];
}
