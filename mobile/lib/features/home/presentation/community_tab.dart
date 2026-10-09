import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/model_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../community/bloc/feed_cubit.dart';
import '../../community/bloc/feed_state.dart';
import '../../community/presentation/comments_sheet.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../upload/presentation/create_document_screen.dart';
import '../../../core/widgets/skeleton.dart';

/// Community feed: filter row (All Posts / My Posts / Create Post)
/// followed by the posts loaded from the backend.
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  late final FeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FeedCubit(
      context.read<PostsRepository>(),
      context.read<BookmarksRepository>(),
      () => context.read<ProfileCubit>().state.profile?.id,
    )..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // Near the bottom of this tab's own list: fetch the next page
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical &&
        n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {
      _cubit.loadMore();
    }
    return false;
  }

  Future<void> _createPost() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDocumentScreen(initialTab: 1),
      ),
    );
    _cubit.load();
  }

  Future<void> _openComments(Post post) async {
    final delta = await showCommentsSheet(context, post.id);
    _cubit.changeCommentCount(post.id, delta);
  }

  Future<void> _confirmDelete(Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) _cubit.deletePost(post);
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<ProfileCubit>().state.profile?.id;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FeedCubit, FeedState>(
        // Show one-off messages (failed like, etc.) as a SnackBar
        listenWhen: (a, b) => a.noticeId != b.noticeId,
        listener: (context, state) {
          if (state.notice == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notice!)));
        },
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView(
              // Slightly narrower side padding = slightly wider post cards
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _FilterChip(
                          label: 'All Posts',
                          selected: !state.onlyMine,
                          onTap: () => _cubit.load(onlyMine: false),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'My Posts',
                          selected: state.onlyMine,
                          onTap: () => _cubit.load(onlyMine: true),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: state.isLoading
                              ? null
                              : () => _cubit.load(),
                        ),
                        // AppButton(
                        //   label: 'Create Post',
                        //   icon: Icons.edit_outlined,
                        //   variant: AppButtonVariant.small,
                        //   expand: false,
                        //   onPressed: _createPost,
                        // ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ..._body(state, myId),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _body(FeedState state, String? myId) {
    if (state.isLoading) return const [SkeletonPostList()];
    if (state.error != null && state.posts.isEmpty) {
      return [ErrorView(message: state.error!, onRetry: () => _cubit.load())];
    }
    if (state.posts.isEmpty) {
      return [
        EmptyView(
          title: state.onlyMine ? 'You have no posts yet' : 'No posts yet',
          message: 'Tap Create Post to start the conversation.',
          icon: Icons.forum_outlined,
        ),
      ];
    }
    return [
      for (final post in state.posts) ...[
        postCardFor(
          post,
          onLike: () => _cubit.toggleLike(post),
          onBookmark: () => _cubit.toggleBookmark(post),
          onComment: () => _openComments(post),
          onDelete: post.author.id == myId ? () => _confirmDelete(post) : null,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
      if (state.isLoadingMore) const SkeletonPostList(count: 1),
    ];
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
