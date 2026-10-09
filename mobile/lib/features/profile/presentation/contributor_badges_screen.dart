import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class _BadgeData {
  const _BadgeData(
    this.icon,
    this.color,
    this.title,
    this.description, {
    this.progress,
    this.progressLabel,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  /// null means the badge is already earned.
  final double? progress;
  final String? progressLabel;

  bool get earned => progress == null;
}

/// Contributor Badges — level/XP summary plus earned and locked badges.
class ContributorBadgesScreen extends StatelessWidget {
  const ContributorBadgesScreen({super.key});

  static const _badges = [
    _BadgeData(
      Icons.upload_file_rounded,
      AppColors.primary,
      'First Upload',
      'Shared your first resource with the campus.',
    ),
    _BadgeData(
      Icons.history_edu_rounded,
      AppColors.accentPurple,
      'PYQ Hero',
      'Uploaded 10 previous year papers.',
    ),
    _BadgeData(
      Icons.verified_rounded,
      AppColors.success,
      'Verified Contributor',
      'Your uploads were verified by batchmates.',
    ),
    _BadgeData(
      Icons.local_fire_department_rounded,
      AppColors.accentOrange,
      '7-Day Streak',
      'Active on Semester Forge 7 days in a row.',
    ),
    _BadgeData(
      Icons.favorite_rounded,
      AppColors.accentPink,
      'Helpful Peer',
      'Reach 500 downloads on your uploads.',
      progress: 0.72,
      progressLabel: '360 / 500',
    ),
    _BadgeData(
      Icons.star_rounded,
      AppColors.warning,
      'Top Rated',
      'Maintain a 4.8+ rating across 20 uploads.',
      progress: 0.42,
      progressLabel: '42 / 100',
    ),
    _BadgeData(
      Icons.workspace_premium_rounded,
      AppColors.accentTeal,
      'Century Club',
      'Upload 100 resources to the vault.',
      progress: 0.42,
      progressLabel: '42 / 100',
    ),
    _BadgeData(
      Icons.emoji_events_rounded,
      AppColors.primary,
      'Campus Legend',
      'Reach Level 10 and mentor 25 students.',
      progress: 0.12,
      progressLabel: 'Level 4 / 10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.earned).length;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Contributor Badges'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEVEL 4', style: AppTextStyles.overline),
                const SizedBox(height: 2),
                Text('Campus Scholar', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1,240 / 1,500 XP',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '260 XP to Campus Mentor',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: const LinearProgressIndicator(
                    value: 1240 / 1500,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '$earned EARNED · ${_badges.length - earned} LOCKED',
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 176,
            ),
            itemBuilder: (context, index) => _BadgeTile(badge: _badges[index]),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    final color = badge.earned ? badge.color : AppColors.textMuted;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(badge.icon, color: color, size: 24),
              ),
              if (!badge.earned)
                const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.textMuted,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.title,
            style: AppTextStyles.bodySemiBold.copyWith(
              fontSize: 14,
              color: badge.earned
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
          const Spacer(),
          if (badge.earned)
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Earned',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(badge.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.progressLabel ?? '',
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
