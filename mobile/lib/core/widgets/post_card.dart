import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'avatar_circle.dart';

/// Optional small attachment preview shown inside a [PostCard].
class PostAttachment {
  const PostAttachment({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

/// Community feed post: author row, title, body, hashtags, optional
/// attachment card, and a Like / Comment / Bookmark action row.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    required this.title,
    required this.body,
    this.online = false,
    this.hashtags = const [],
    this.attachment,
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.liked = false,
    this.bookmarked = false,
    this.onLike,
    this.onComment,
    this.onBookmark,
  });

  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String title;
  final String body;
  final bool online;
  final List<String> hashtags;
  final PostAttachment? attachment;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final bool liked;
  final bool bookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: authorName, size: 36, online: online),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
                    ),
                    Text(
                      '$authorRole · $timeAgo',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(body, style: AppTextStyles.bodyMedium),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: hashtags
                  .map(
                    (tag) => Text(
                      '#$tag',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (attachment != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment!.title,
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          attachment!.subtitle,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionButton(
                icon: liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                label: 'Like ($likeCount)',
                color: liked ? AppColors.primary : AppColors.textSecondary,
                onTap: onLike,
              ),
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comment ($commentCount)',
                color: AppColors.textSecondary,
                onTap: onComment,
              ),
              _ActionButton(
                icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: 'Bookmark ($bookmarkCount)',
                color: bookmarked ? AppColors.primary : AppColors.textSecondary,
                onTap: onBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
