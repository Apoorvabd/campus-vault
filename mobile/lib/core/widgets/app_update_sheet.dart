import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_update_repository.dart';
import '../network/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Full flow: checks backend for update, compares versions, and displays the sheet if needed.
Future<void> checkForAppUpdate(
  BuildContext context, {
  required ApiClient apiClient,
  int currentVersionCode = 1,
  String currentVersionName = '1.0.0',
  String platform = 'android',
  bool showUpToDateMessage = false,
}) async {
  try {
    final repo = AppUpdateRepository(apiClient);
    final update = await repo.checkUpdate(
      platform: platform,
      currentVersionCode: currentVersionCode,
    );

    if (!context.mounted) return;

    if (update != null && update.updateAvailable) {
      await showAppUpdateSheet(
        context,
        version: update.latestVersionName,
        updatePoints: update.releaseNotesList.isNotEmpty
            ? update.releaseNotesList
            : (update.releaseNotes.isNotEmpty
                ? [update.releaseNotes]
                : const [
                    'Exciting new features and optimizations.',
                    'Bug fixes and stability improvements.',
                  ]),
        isForceUpdate: update.forceUpdate,
        downloadUrl: update.downloadUrl,
      );
    } else if (showUpToDateMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your app is up to date! 🎉'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  } catch (e) {
    if (showUpToDateMessage && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not check for updates: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Shows an App Update popup/bottom sheet when a newer app version is available.
Future<void> showAppUpdateSheet(
  BuildContext context, {
  String version = '1.1.0',
  List<String> updatePoints = const [
    'Brand new Exam Mode to view all semester notes in one scroll.',
    'Faster PYQ search with instant subject filtering.',
    'Resolved offline storage issues & improved PDF rendering speed.',
    'Bug fixes and overall stability improvements.',
  ],
  bool isForceUpdate = false,
  String? downloadUrl,
  VoidCallback? onUpdate,
  VoidCallback? onLater,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: !isForceUpdate,
    enableDrag: !isForceUpdate,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => PopScope(
      canPop: !isForceUpdate,
      child: AppUpdateSheet(
        version: version,
        updatePoints: updatePoints,
        isForceUpdate: isForceUpdate,
        downloadUrl: downloadUrl,
        onUpdate: () async {
          Navigator.of(sheetContext).pop();
          if (onUpdate != null) {
            onUpdate();
          } else if (downloadUrl != null && downloadUrl.isNotEmpty) {
            final uri = Uri.tryParse(downloadUrl);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        onLater: () {
          Navigator.of(sheetContext).pop();
          onLater?.call();
        },
      ),
    ),
  );
}

/// The UI content for the App Update popup sheet.
class AppUpdateSheet extends StatelessWidget {
  const AppUpdateSheet({
    super.key,
    required this.version,
    required this.updatePoints,
    this.isForceUpdate = false,
    this.downloadUrl,
    this.onUpdate,
    this.onLater,
  });

  final String version;
  final List<String> updatePoints;
  final bool isForceUpdate;
  final String? downloadUrl;
  final VoidCallback? onUpdate;
  final VoidCallback? onLater;

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
          // Drag handle
          if (!isForceUpdate)
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
          const SizedBox(height: AppSpacing.md),

          // Icon / Badge
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.system_update_alt_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title & Version Tag
          Center(
            child: Text(
              'Update Available!',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Version $version is here',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // "What's New" Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      "What's new in this version",
                      style: AppTextStyles.bodySemiBold.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...updatePoints.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              point,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Update Button
          AppButton(
            label: 'Update Now',
            icon: Icons.arrow_forward_rounded,
            onPressed: onUpdate,
          ),

          // Optional "Maybe Later"
          if (!isForceUpdate) ...[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton(
                onPressed: onLater ?? () => Navigator.of(context).pop(),
                child: Text(
                  'Maybe Later',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
