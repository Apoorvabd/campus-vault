import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/models/paged.dart';
import '../../../core/models/resource.dart';
import '../../../core/network/api_exception.dart';
import 'resource_list_state.dart';

/// Which resources to list. Used by Subject Detail and Search.
class ResourceQuery {
  const ResourceQuery({
    this.subjectId,
    this.courseId,
    this.semester,
    this.type,
    this.search,
    this.sortByDownloads = false,
    this.bookmarkedOnly = false,
  });

  final String? subjectId;
  final String? courseId;
  final int? semester;
  final ResourceType? type;
  final String? search;
  final bool sortByDownloads;

  /// Only the user's bookmarked resources (of [subjectId] / [type]).
  final bool bookmarkedOnly;
}

/// A paginated list of resources: load the first page, load more, and
/// toggle bookmarks optimistically.
class ResourceListCubit extends Cubit<ResourceListState> {
  ResourceListCubit(this._resources, this._bookmarks)
    : super(const ResourceListState());

  final ResourcesRepository _resources;
  final BookmarksRepository _bookmarks;

  static const _pageSize = 20;

  ResourceQuery? _query;

  /// Starts over with a new query (page 1). The old list is cleared.
  Future<void> load(ResourceQuery query) async {
    _query = query;
    emit(const ResourceListState(isLoading: true));
    try {
      final result = await _fetch(query, 1);
      // Ignore the answer if the user already started another query
      if (isClosed || _query != query) return;
      emit(
        ResourceListState(
          items: result.items,
          page: result.page,
          total: result.total,
          hasMore: result.hasMore,
          hasLoaded: true,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed || _query != query) return;
      emit(ResourceListState(hasLoaded: true, error: e.message));
    }
  }

  Future<void> refresh() {
    final query = _query;
    return query == null ? Future.value() : load(query);
  }

  Future<void> loadMore() async {
    final query = _query;
    if (query == null ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result = await _fetch(query, state.page + 1);
      if (isClosed || _query != query) return;
      emit(
        state.copyWith(
          items: [...state.items, ...result.items],
          page: result.page,
          total: result.total,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed || _query != query) return;
      emit(state.copyWith(isLoadingMore: false, actionError: e.message));
    }
  }

  /// Flips the bookmark right away, then tells the server. Undoes it on error.
  Future<void> toggleBookmark(Resource resource) async {
    final wanted = !resource.isBookmarked;
    _setBookmark(resource.id, wanted);
    try {
      await _bookmarks.setResourceBookmarked(resource.id, wanted);
    } on ApiException catch (e) {
      if (isClosed) return;
      _setBookmark(resource.id, !wanted);
      emit(state.copyWith(actionError: e.message));
    }
  }

  void _setBookmark(String id, bool value) {
    emit(
      state.copyWith(
        items: [
          for (final r in state.items)
            r.id == id ? r.copyWith(isBookmarked: value) : r,
        ],
      ),
    );
  }

  /// The bookmarks endpoint can't filter by subject, so we read all of the
  /// user's bookmarks (50 per request) and filter here. Bookmarks are few.
  Future<PageResult<Resource>> _fetchBookmarked(ResourceQuery q) async {
    final all = <Resource>[];
    var page = 1;
    while (true) {
      final result = await _bookmarks.savedResources(page: page, limit: 50);
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    final matching = all
        .where(
          (r) =>
              (q.subjectId == null || r.subjectId == q.subjectId) &&
              (q.type == null || r.type == q.type),
        )
        .toList();
    return PageResult(
      items: matching,
      page: 1,
      totalPages: 1,
      total: matching.length,
    );
  }

  Future<PageResult<Resource>> _fetch(ResourceQuery q, int page) {
    if (q.bookmarkedOnly) return _fetchBookmarked(q);
    return _fetchOnline(q, page);
  }

  Future<PageResult<Resource>> _fetchOnline(ResourceQuery q, int page) =>
      _resources.list(
        subjectId: q.subjectId,
        courseId: q.courseId,
        semester: q.semester,
        type: q.type,
        search: q.search,
        sortByDownloads: q.sortByDownloads,
        page: page,
        limit: _pageSize,
      );
}
