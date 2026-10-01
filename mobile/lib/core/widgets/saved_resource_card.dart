import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'status_chip.dart';

/// Card used on the Saved Vault screen: badge + star/bookmark row, title,
/// subject (as a link-colored line), meta (degree/sem), then a
/// pages/size line with a trailing action button.
class SavedResourceCard extends StatelessWidget {
  const SavedResourceCard({
    super.key,
    required this.badgeLabel,
    required this.badgeVariant,
    required this.title,
    required this.subject,
    required this.meta,
    required this.fileInfo,
    required this.actionLabel,
    required this.actionIcon,
    this.starred = false,
    this.bookmarked = true,
    this.onStar,
    this.onBookmark,
    this.onAction,
  });

  final String badgeLabel;
  final StatusChipVariant badgeVariant;
  final String title;
  final String subject;
  final String meta;
  final String fileInfo;
  final String actionLabel;
  final IconData actionIcon;
  final bool starred;
  final bool bookmarked;
  final VoidCallback? onStar;
  final VoidCallback? onBookmark;
  final VoidCallback? onAction;

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
              Row(
                children: [
                  _IconButtonSmall(
                    icon: starred
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: starred ? AppColors.warning : AppColors.textMuted,
                    onTap: onStar,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _IconButtonSmall(
                    icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.primary,
                    onTap: onBookmark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            subject,
            style: AppTextStyles.bodySemiBold.copyWith(
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text('• $meta', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(fileInfo, style: AppTextStyles.caption)),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 16, color: Colors.white),
                label: Text(
                  actionLabel,
                  style: AppTextStyles.buttonText.copyWith(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButtonSmall extends StatelessWidget {
  const _IconButtonSmall({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color),
    );
  }
}
