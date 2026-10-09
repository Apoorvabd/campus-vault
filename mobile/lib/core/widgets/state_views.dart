import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Centered spinner for a screen or section that is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
}

/// Error message with an optional retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Try again',
                  expand: false,
                  variant: AppButtonVariant.outline,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      );
}

/// Friendly "nothing here yet" message.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTextStyles.bodySemiBold),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      );
}
