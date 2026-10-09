import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/network/api_exception.dart';
import 'saved_list_state.dart';

/// Bookmarked resources (first tab of the Saved screen).
class SavedResourcesCubit extends Cubit<SavedListState<Resource>> {
  SavedResourcesCubit(this._bookmarks, this._resources)
    : super(const SavedListState());

  final BookmarksRepository _bookmarks;
  final ResourcesRepository _resources;

  /// Loads the first page (also used for pull-to-refresh and retry).
  Future<void> load() async {
    // Keep the old list on screen while refreshing
    emit(state.copyWith(isLoading: true, clearLoadError: true));
    try {
      final result = await _bookmarks.savedResources(page: 1);
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
      final result = await _bookmarks.savedResources(page: state.page + 1);
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

  /// Un-saves a resource: removed from the list right away, put back if the
  /// request fails.
  Future<void> unsave(Resource resource) async {
    final before = state;
    emit(
      state.copyWith(
        items: state.items.where((r) => r.id != resource.id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      ),
    );
    try {
      await _bookmarks.setResourceBookmarked(resource.id, false);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(before.copyWith(actionError: e.message));
    }
  }

  /// Counts the open as a download. Failures are ignored on purpose.
  Future<void> recordOpen(Resource resource) async {
    try {
      await _resources.recordDownload(resource.id);
    } catch (_) {}
  }

  // Everything on this screen is saved, so make sure the card shows that
  List<Resource> _markSaved(List<Resource> items) =>
      items.map((r) => r.copyWith(isBookmarked: true)).toList();
}
