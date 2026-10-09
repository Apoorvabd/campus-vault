import 'package:equatable/equatable.dart';
import '../../../core/models/resource.dart';

class ResourceListState extends Equatable {
  const ResourceListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasLoaded = false,
    this.error,
    this.actionError,
  });

  final List<Resource> items; // everything loaded so far (all pages)
  final int page; // last page loaded
  final int total; // total matches on the server, from meta.total
  final bool hasMore;
  final bool isLoading; // first page of a new query
  final bool isLoadingMore; // next page
  final bool hasLoaded; // true once a query finished at least once
  final String? error; // the list failed to load
  final String? actionError; // a bookmark failed; shown as a SnackBar

  ResourceListState copyWith({
    List<Resource>? items,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasLoaded,
    String? error,
    String? actionError,
  }) {
    // error and actionError are not kept: each new state clears them
    return ResourceListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: error,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    total,
    hasMore,
    isLoading,
    isLoadingMore,
    hasLoaded,
    error,
    actionError,
  ];
}
