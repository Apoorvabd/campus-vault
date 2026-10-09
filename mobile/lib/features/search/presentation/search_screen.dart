import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/home_top_bar.dart';
import '../../../core/widgets/model_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../resources/bloc/resource_list_cubit.dart';
import '../../resources/bloc/resource_list_state.dart';
import '../../resources/resource_actions.dart';
import '../data/recent_searches.dart';
import '../../../core/widgets/skeleton.dart';

/// Search screen: filters + recent searches until the user submits a query,
/// then the real results from the backend (paginated).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Don't hit the API for shorter text, and wait until typing pauses
  static const _minChars = 4;
  // Search only after the user has stopped typing for this long
  static const _typingPause = Duration(milliseconds: 800);

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _recentStore = RecentSearches();
  late final ResourceListCubit _cubit;
  Timer? _debounce;
  bool _myCourseOnly = false; // off = search every course

  List<String> _recent = [];
  String? _query; // the submitted query; null until the first search
  ResourceType? _type;
  int? _semester;
  bool _sortByDownloads = true;

  @override
  void initState() {
    super.initState();
    _cubit = ResourceListCubit(
      context.read<ResourcesRepository>(),
      context.read<BookmarksRepository>(),
    );
    _recentStore.load().then((list) {
      if (mounted) setState(() => _recent = list);
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _cubit.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Runs the search with the current filters. Pass [saveRecent] false when
  /// only a filter changed.
  void _runSearch(String text, {bool saveRecent = true}) {
    final query = text.trim();
    if (query.isEmpty) return;
    if (query.length < _minChars) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Type at least 4 characters to search')),
        );
      return;
    }
    // Close the keyboard only when the user submits (Enter / tapping a recent
    // search). Typing-pause and filter searches must leave it open.
    if (saveRecent) FocusScope.of(context).unfocus();
    setState(() => _query = query);
    _cubit.load(ResourceQuery(
      search: query,
      // Only narrow to the user's course when they switch "My course" on
      courseId: _myCourseOnly
          ? context.read<ProfileCubit>().state.profile?.courseId
          : null,
      semester: _semester,
      type: _type,
      sortByDownloads: _sortByDownloads,
    ));
    if (saveRecent) {
      _recentStore.add(query).then((list) {
        if (mounted) setState(() => _recent = list);
      });
    }
  }

  /// Search while typing, after a short pause (not saved to recent searches).
  void _onTextChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query.isEmpty) {
      setState(() => _query = null); // back to recent searches
      return;
    }
    if (query.length < _minChars) return;
    _debounce = Timer(_typingPause, () {
      if (mounted) _runSearch(query, saveRecent: false);
    });
  }

  void _rerunIfSearched() {
    if (_query != null) _runSearch(_query!, saveRecent: false);
  }

  Future<void> _clearRecent() async {
    await _recentStore.clear();
    if (mounted) setState(() => _recent = []);
  }

  @override
  Widget build(BuildContext context) {
    final totalSemesters =
        context.read<ProfileCubit>().state.profile?.totalSemesters ?? 8;

    return Scaffold(
      appBar: HomeTopBar(
        showBackButton: true,
        searchController: _controller,
        readOnly: false,
        autofocus: true,
        onChanged: _onTextChanged,
        onSubmitted: _runSearch,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: _type?.label ?? 'Type: All',
                    active: _type != null,
                    onTap: () async {
                      final picked = await _pick<ResourceType?>(
                        'Resource type',
                        [null, ...ResourceType.values],
                        (t) => t?.label ?? 'All types',
                        _type,
                      );
                      if (picked == null) return; // dismissed
                      setState(() => _type = picked.value);
                      _rerunIfSearched();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: _semester == null ? 'Sem: Any' : 'Sem: $_semester',
                    active: _semester != null,
                    onTap: () async {
                      final picked = await _pick<int?>(
                        'Semester',
                        [null, for (var i = 1; i <= totalSemesters; i++) i],
                        (s) => s == null ? 'Any semester' : 'Semester $s',
                        _semester,
                      );
                      if (picked == null) return;
                      setState(() => _semester = picked.value);
                      _rerunIfSearched();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'My course',
                    active: _myCourseOnly,
                    onTap: () {
                      setState(() => _myCourseOnly = !_myCourseOnly);
                      _rerunIfSearched();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: _sortByDownloads ? 'Most Downloaded' : 'Newest',
                    active: false,
                    onTap: () async {
                      final picked = await _pick<bool>(
                        'Sort by',
                        [true, false],
                        (b) => b ? 'Most Downloaded' : 'Newest',
                        _sortByDownloads,
                      );
                      if (picked == null) return;
                      setState(() => _sortByDownloads = picked.value);
                      _rerunIfSearched();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _query == null
                  ? _buildRecentSearches()
                  : BlocProvider.value(
                      value: _cubit,
                      child: _buildResults(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet with one row per option. Returns null when dismissed; the
  /// answer is wrapped in [_Picked] so "no filter" (a null value) can be told
  /// apart from "dismissed".
  Future<_Picked<T>?> _pick<T>(
    String title,
    List<T> options,
    String Function(T) labelOf,
    T current,
  ) {
    return showModalBottomSheet<_Picked<T>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(title, style: AppTextStyles.h2),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        title: Text(labelOf(option)),
                        trailing: option == current
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () =>
                            Navigator.pop(sheetContext, _Picked<T>(option)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return BlocConsumer<ResourceListCubit, ResourceListState>(
      listenWhen: (a, b) => b.actionError != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.actionError!))),
      builder: (context, state) {
        if (state.isLoading || !state.hasLoaded) {
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: SkeletonResourceList(),
          );
        }
        if (state.error != null) {
          return ErrorView(message: state.error!, onRetry: _cubit.refresh);
        }
        if (state.items.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo.mark(height: 48),
              const SizedBox(height: AppSpacing.md),
              EmptyView(
                title: 'No results for "$_query"',
                message: 'Try different words or loosen the filters.',
                icon: Icons.search_off,
              ),
            ],
          );
        }
        final repository = context.read<ResourcesRepository>();
        return ListView(
          controller: _scroll,
          children: [
            Text('Results', style: AppTextStyles.h1),
            Text(
              '${state.total} ${state.total == 1 ? 'result' : 'results'} found',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final resource in state.items) ...[
              resourceCardFor(
                resource,
                onAction: () => openResource(context, repository, resource),
                onBookmark: () => _cubit.toggleBookmark(resource),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (state.isLoadingMore) const SkeletonResourceList(count: 1),
          ],
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    if (_recent.isEmpty) {
      return const Center(
        child: EmptyView(
          title: 'Search Semester Forge',
          message: 'Find PYQs, notes, syllabus and more.',
          icon: Icons.search,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: AppTextStyles.h2),
            GestureDetector(
              onTap: _clearRecent,
              child: Text(
                'Clear',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _recent
              .map(
                (term) => GestureDetector(
                  onTap: () {
                    _controller.text = term;
                    _runSearch(term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(term, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Wraps a picked value so a null choice differs from a dismissed sheet.
class _Picked<T> {
  const _Picked(this.value);
  final T value;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active; // a filter is applied
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : null,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
