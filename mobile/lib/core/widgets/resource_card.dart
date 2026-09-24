import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'avatar_circle.dart';
import 'status_chip.dart';

/// Card used for feed posts, PYQ/Notes listings and search results:
/// badge row → title → meta line → uploader row with an action button.
class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.badgeLabel,
    required this.badgeVariant,
    required this.title,
    required this.meta,
    required this.uploaderName,
    required this.actionLabel,
    this.onAction,
    this.onBookmark,
    this.bookmarked = false,
  });

  final String badgeLabel;
  final StatusChipVariant badgeVariant;
  final String title;
  final String meta;
  final String uploaderName;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onBookmark;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(label: badgeLabel, variant: badgeVariant),
              IconButton(
                onPressed: onBookmark,
                icon: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(meta, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AvatarCircle(name: uploaderName, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  uploaderName,
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppButton(
                label: actionLabel,
                icon: Icons.remove_red_eye_outlined,
                variant: AppButtonVariant.small,
                expand: false,
                onPressed: onAction,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
