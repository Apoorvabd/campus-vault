import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Where the user wants the document to go.
enum SaveChoice { online, local }

/// Asks "online or on this device?" before a document is saved. Online is
/// promoted (everyone benefits, the uploader earns points); saving on the
/// device stays available for private files. Returns null when dismissed.
///
/// [canSaveLocally] is false for external links, which have no file to keep.
Future<SaveChoice?> showSaveChoiceSheet(
  BuildContext context, {
  required bool canSaveLocally,
}) {
  return showModalBottomSheet<SaveChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SaveChoiceSheet(canSaveLocally: canSaveLocally),
  );
}

class _SaveChoiceSheet extends StatelessWidget {
  const _SaveChoiceSheet({required this.canSaveLocally});

  final bool canSaveLocally;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Where should we save this?', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            'Pick how you want to keep this document.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ChoiceCard(
            highlighted: true,
            icon: Icons.cloud_upload_outlined,
            title: 'Upload online',
            badge: 'Recommended',
            points: const [
              'Everyone on campus can see it and use it',
              'You earn points when others use your uploads',
              'Reviewed by an admin before it goes live',
            ],
            onTap: () => Navigator.pop(context, SaveChoice.online),
          ),
          const SizedBox(height: AppSpacing.md),
          _ChoiceCard(
            highlighted: false,
            icon: Icons.phone_android_outlined,
            title: 'Save on this device',
            points: canSaveLocally
                ? const [
                    'Private: only you can see it',
                    'Opens offline, even without internet',
                    'Not shared, so no points',
                  ]
                : const [
                    'Links can\'t be kept on your device. Choose a file to save it here.',
                  ],
            enabled: canSaveLocally,
            onTap: () => Navigator.pop(context, SaveChoice.local),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.highlighted,
    required this.icon,
    required this.title,
    required this.points,
    required this.onTap,
    this.badge,
    this.enabled = true,
  });

  final bool highlighted;
  final IconData icon;
  final String title;
  final String? badge;
  final List<String> points;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = highlighted ? AppColors.primary : AppColors.textSecondary;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: highlighted ? AppColors.primary : AppColors.border,
              width: highlighted ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 17),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final point in points)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        enabled ? Icons.check_circle : Icons.info_outline,
                        size: 16,
                        color: accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          point,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
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
}
