import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/comments_cubit.dart';
import '../bloc/comments_state.dart';
import '../../../core/widgets/skeleton.dart';

/// Opens the comments of [postId]. Completes when the sheet closes with the
/// change in comment count (e.g. +2 or -1) so the feed can update its card.
Future<int> showCommentsSheet(BuildContext context, String postId) async {
  final cubit = CommentsCubit(context.read<PostsRepository>(), postId)..load();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _CommentsSheet()),
  );
  final delta = cubit.state.delta;
  cubit.close();
  return delta;
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet();

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await context.read<CommentsCubit>().add(_input.text);
    if (ok && mounted) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<ProfileCubit>().state.profile?.id;
    final media = MediaQuery.of(context);
    // Keeps the input above the keyboard, or above the system navigation bar
    // when the keyboard is closed
    final bottomGap = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Comments', style: AppTextStyles.bodySemiBold),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, state) {
                  if (state.isLoading) return const SkeletonCommentList();
                  if (state.comments.isEmpty && state.error != null) {
                    return ErrorView(
                      message: state.error!,
                      onRetry: context.read<CommentsCubit>().load,
                    );
                  }
                  if (state.comments.isEmpty) {
                    return const EmptyView(
                      title: 'No comments yet',
                      message: 'Be the first to say something.',
                      icon: Icons.chat_bubble_outline,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.comments.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == state.comments.length) {
                        return Center(
                          child: state.isLoadingMore
                              ? const SizedBox(
                                  height: 80,
                                  child: SkeletonCommentList(count: 1),
                                )
                              : TextButton(
                                  onPressed: context
                                      .read<CommentsCubit>()
                                      .loadMore,
                                  child: const Text('Load more comments'),
                                ),
                        );
                      }
                      final comment = state.comments[i];
                      return _CommentTile(
                        comment: comment,
                        isMine: comment.userId == myId,
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<CommentsCubit, CommentsState>(
              buildWhen: (a, b) =>
                  a.error != b.error || a.isSending != b.isSending,
              builder: (context, state) => Column(
                children: [
                  if (state.error != null && state.comments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        state.error!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          // One soft rounded box; the TextField draws no border
                          // of its own (the app theme would add an outline)
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _input,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 1000,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                counterText: '',
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: state.isSending
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Material(
                                  color: AppColors.primary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _send,
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.isMine});

  final Comment comment;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarCircle(name: comment.userName, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeAgo(comment.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.content, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          if (isMine)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.textSecondary,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () => context.read<CommentsCubit>().delete(comment),
            ),
        ],
      ),
    );
  }
}
