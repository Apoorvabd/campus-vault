import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'avatar_circle.dart';
import 'status_chip.dart';

/// Card used for PYQ/Notes listings, saved resources and search results:
/// badge + bookmark → title → subject · semester → uploader · views + Open.
class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.badgeLabel,
    required this.badgeVariant,
    required this.title,
    this.subject,
    this.semester,
    required this.uploaderName,
    this.views = 0,
    required this.actionLabel,
    this.onAction,
    this.onBookmark,
    this.bookmarked = false,
  });

  final String badgeLabel;
  final StatusChipVariant badgeVariant;
  final String title;
  final String? subject;
  final int? semester;
  final String uploaderName;
  final int views;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onBookmark;
  final bool bookmarked;

  /// "Calculus · Sem 5", or whichever part exists.
  String get _subjectLine => [
    if (subject != null && subject!.isNotEmpty) subject!,
    if (semester != null) 'Sem $semester',
  ].join(' · ');

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
                // Saved is black and filled; unsaved is a darker outline
                icon: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: bookmarked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
          if (_subjectLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _subjectLine,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AvatarCircle(name: uploaderName, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        uploaderName,
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (views > 0)
                      Text(
                        ' · ${compactCount(views)} views',
                        style: AppTextStyles.caption,
                      ),
                  ],
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
