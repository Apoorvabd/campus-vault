import 'package:flutter/material.dart';
import '../../community/presentation/comments_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_navigation.dart';
import '../../../core/navigation/tab_shell.dart';
import '../../resources/resource_actions.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/models/resource.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/model_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../../local_vault/bloc/local_vault_state.dart';
import '../../local_vault/presentation/add_local_file_sheet.dart';
import '../../local_vault/presentation/local_vault_actions.dart';
import '../../profile/presentation/storage_cache_screen.dart';
import '../bloc/saved_list_state.dart';
import '../bloc/saved_posts_cubit.dart';
import '../bloc/saved_resources_cubit.dart';
import '../../../core/widgets/skeleton.dart';

/// Saved screen — everything the user kept: saved posts, bookmarked
/// resources and files saved on this device, with filters on top.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

enum _MainFilter { all, posts, resources }

enum _ResourceFilter { all, bookmarked, local }

class _SavedScreenState extends State<SavedScreen> {
  static const _navIndex = 3;
  static const _showCacheCard = false;
  _MainFilter _main = _MainFilter.all;
  _ResourceFilter _sub = _ResourceFilter.all;
  String? _subjectFilter; // null = all subjects

  late final SavedResourcesCubit _resourcesCubit;
  late final SavedPostsCubit _postsCubit;

  @override
  void initState() {
    super.initState();
    _resourcesCubit = SavedResourcesCubit(
      context.read<BookmarksRepository>(),
      context.read<ResourcesRepository>(),
    )..load();
    _postsCubit = SavedPostsCubit(
      context.read<BookmarksRepository>(),
      context.read<PostsRepository>(),
    )..load();
    mainTabIndex.addListener(_onTabChanged);
  }

  /// The tab stays alive in the shell, so refresh when the user comes back.
  void _onTabChanged() {
    if (mainTabIndex.value != _navIndex) return;
    _resourcesCubit.load();
    _postsCubit.load();
    context.read<LocalVaultCubit>().load();
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_onTabChanged);
    _resourcesCubit.close();
    _postsCubit.close();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openResource(Resource resource) async {
    final url = resource.fileUrl;
    if (url == null) {
      _showMessage('No file attached');
      return;
    }
    final opened = await openLinkInApp(url);
    if (!mounted) return;
    if (opened) {
      _resourcesCubit.recordOpen(resource);
    } else {
      _showMessage('Could not open this file');
    }
  }

  void _setMain(_MainFilter value) => setState(() {
    _main = value;
    _sub = _ResourceFilter.all;
    _subjectFilter = null;
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _resourcesCubit),
        BlocProvider.value(value: _postsCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SavedResourcesCubit, SavedListState<Resource>>(
            listenWhen: (_, now) => now.actionError != null,
            listener: (context, state) => _showMessage(state.actionError!),
          ),
          BlocListener<SavedPostsCubit, SavedListState<Post>>(
            listenWhen: (_, now) => now.actionError != null,
            listener: (context, state) => _showMessage(state.actionError!),
          ),
          BlocListener<LocalVaultCubit, LocalVaultState>(
            listenWhen: (_, now) => now.error != null,
            listener: (context, state) => _showMessage(state.error!),
          ),
        ],
        child: AppShellScaffold(
          currentIndex: _navIndex,
          onSearchTap: () => openSearch(context),
          onNavTap: (index) {
            if (index == _navIndex) return;
            goToTab(context, index);
          },
          body: RefreshIndicator(
            onRefresh: () => Future.wait([
              _resourcesCubit.load(),
              _postsCubit.load(),
              context.read<LocalVaultCubit>().load(),
            ]),
            child: NotificationListener<ScrollNotification>(
              // Load the next page when the user nears the bottom
              onNotification: (n) {
                if (n.metrics.extentAfter < 300) {
                  if (_showsBookmarked) _resourcesCubit.loadMore();
                  if (_showsPosts) _postsCubit.loadMore();
                }
                return false;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Less space above the title and below the last card
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved',
                        style: AppTextStyles.displayBold.copyWith(fontSize: 29),
                      ),
                      TextButton.icon(
                        onPressed: () => showAddLocalFileSheet(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add file'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Builder: a context that sits below the providers above
                  Builder(builder: _buildContent),
                  // Hidden for now; flip _showCacheCard to bring it back
                  if (_showCacheCard) ...[
                    const SizedBox(height: AppSpacing.md),
                    const _CacheCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // What the current filters let through
  bool get _showsPosts => _main != _MainFilter.resources;
  bool get _showsBookmarked =>
      _main == _MainFilter.all ||
      (_main == _MainFilter.resources && _sub != _ResourceFilter.local);
  bool get _showsLocal =>
      _main == _MainFilter.all ||
      (_main == _MainFilter.resources && _sub != _ResourceFilter.bookmarked);

  /// Filter chips + one mixed list of everything the user saved.
  Widget _buildContent(BuildContext context) {
    final res = context.watch<SavedResourcesCubit>().state;
    final posts = context.watch<SavedPostsCubit>().state;
    final local = context.watch<LocalVaultCubit>().state;

    final bookmarkedCount = res.total;
    final localCount = local.items.length;
    final postCount = posts.total;

    // Subject chips only make sense for resources (posts have no subject)
    final inResources = _main == _MainFilter.resources;
    final subjects = <String>{
      if (_showsBookmarked)
        for (final r in res.items)
          if (r.subject != null) r.subject!.name,
      if (_showsLocal)
        for (final i in local.items) i.subjectName,
    }.toList();
    final filter = inResources && subjects.contains(_subjectFilter)
        ? _subjectFilter
        : null;

    final localShown = local.items.where(
      (i) => _showsLocal && (filter == null || i.subjectName == filter),
    );
    final bookmarkedShown = res.items.where(
      (r) => _showsBookmarked && (filter == null || r.subject?.name == filter),
    );

    final cards = <Widget>[
      for (final item in localShown) ...[
        const _SourceTag(icon: Icons.phone_android, label: 'Saved on device'),
        localVaultCardFor(context, item),
        const SizedBox(height: 10),
      ],
      for (final resource in bookmarkedShown) ...[
        const _SourceTag(icon: Icons.bookmark, label: 'Bookmarked resource'),
        savedResourceCardFor(
          resource,
          onAction: () => _openResource(resource),
          onBookmark: () => _resourcesCubit.unsave(resource),
        ),
        const SizedBox(height: 10),
      ],
      if (_showsPosts)
        for (final post in posts.items) ...[
          const _SourceTag(icon: Icons.bookmark, label: 'Saved post'),
          postCardFor(
            post,
            onLike: () => _postsCubit.toggleLike(post),
            onComment: () => showCommentsSheet(context, post.id),
            onBookmark: () => _postsCubit.unsave(post),
            compact: true,
          ),
          const SizedBox(height: 10),
        ],
    ];

    final loading =
        (_showsBookmarked && res.isLoading && res.page == 0) ||
        (_showsPosts && posts.isLoading && posts.page == 0) ||
        (_showsLocal && local.isLoading);
    final loadError =
        (_showsBookmarked && res.items.isEmpty ? res.loadError : null) ??
        (_showsPosts && posts.items.isEmpty ? posts.loadError : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterRow(
          chips: [
            _ChipData(
              'All',
              bookmarkedCount + localCount + postCount,
              _main == _MainFilter.all,
              () => _setMain(_MainFilter.all),
            ),
            _ChipData(
              'Posts',
              postCount,
              _main == _MainFilter.posts,
              () => _setMain(_MainFilter.posts),
            ),
            _ChipData(
              'Resources',
              bookmarkedCount + localCount,
              _main == _MainFilter.resources,
              () => _setMain(_MainFilter.resources),
            ),
          ],
        ),
        if (inResources) ...[
          const SizedBox(height: AppSpacing.sm),
          _FilterRow(
            small: true,
            chips: [
              _ChipData(
                'All',
                bookmarkedCount + localCount,
                _sub == _ResourceFilter.all,
                () => setState(() => _sub = _ResourceFilter.all),
              ),
              _ChipData(
                'Bookmarked',
                bookmarkedCount,
                _sub == _ResourceFilter.bookmarked,
                () => setState(() => _sub = _ResourceFilter.bookmarked),
              ),
              _ChipData(
                'Locally saved',
                localCount,
                _sub == _ResourceFilter.local,
                () => setState(() => _sub = _ResourceFilter.local),
              ),
            ],
          ),
          if (subjects.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            _SubjectFilters(
              subjects: subjects,
              selected: filter,
              onSelected: (s) => setState(() => _subjectFilter = s),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.lg),
        if (cards.isNotEmpty) ...[
          ...cards,
          if ((_showsBookmarked && res.isLoadingMore) ||
              (_showsPosts && posts.isLoadingMore))
            _showsPosts && !_showsBookmarked
                ? const SkeletonPostList(count: 1)
                : const SkeletonResourceList(count: 1),
        ] else if (loading)
          _showsPosts && !_showsBookmarked && !_showsLocal
              ? const SkeletonPostList()
              : const SkeletonResourceList()
        else if (loadError != null)
          ErrorView(
            message: loadError,
            onRetry: () {
              _resourcesCubit.load();
              _postsCubit.load();
            },
          )
        else
          _emptyFor(),
      ],
    );
  }

  Widget _emptyFor() {
    if (_main == _MainFilter.posts) {
      return const _EmptySaved(
        title: 'No saved posts yet',
        message: 'Bookmark posts from the feed to read them later.',
      );
    }
    if (_main == _MainFilter.resources) {
      return _EmptySaved(
        title: _sub == _ResourceFilter.local
            ? 'Nothing saved on this device'
            : 'No saved resources yet',
        message: _sub == _ResourceFilter.local
            ? 'Tap "Add file" to keep a PDF from your phone here.'
            : 'Bookmark a resource or add a file from your phone.',
      );
    }
    return const _EmptySaved(
      title: 'Nothing saved yet',
      message: 'Bookmark posts and resources, or add a file from your phone.',
    );
  }
}

class _ChipData {
  const _ChipData(this.label, this.count, this.selected, this.onTap);

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
}

/// A horizontal row of filter pills, each showing its own count.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.chips, this.small = false});

  final List<_ChipData> chips;
  final bool small; // the second-level row is a bit lighter

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: small ? 32 : 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final selectedColor = small
              ? AppColors.textPrimary
              : AppColors.primary;
          return GestureDetector(
            onTap: chip.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chip.selected ? selectedColor : AppColors.surface,
                border: chip.selected
                    ? null
                    : Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${chip.label} · ${chip.count}',
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: small ? 12 : 13,
                  color: chip.selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small label above a card saying what kind of "saved" it is.
class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        const AppLogo.mark(height: 48),
        EmptyView(title: title, message: message, icon: Icons.bookmark_border),
      ],
    );
  }
}

class _SubjectFilters extends StatelessWidget {
  const _SubjectFilters({
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  final List<String> subjects;
  final String? selected; // null = All Subjects
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = ['All Subjects', ...subjects];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == 0
              ? selected == null
              : labels[index] == selected;
          return GestureDetector(
            onTap: () => onSelected(index == 0 ? null : labels[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                border: isSelected ? null : Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                labels[index],
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Link to the (demo) cache screen. No storage numbers are shown here.
class _CacheCard extends StatelessWidget {
  const _CacheCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StorageCacheScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.sd_storage_outlined,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Storage & Cache', style: AppTextStyles.bodySemiBold),
              ],
            ),
            Text(
              'Manage & Clear Cache ›',
              style: AppTextStyles.bodySemiBold.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
