import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "STEP X OF Y" label + progress bar + "N% Completed", used on the
/// signup flow.
class ProgressStepHeader extends StatelessWidget {
  const ProgressStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  double get _progress => currentStep / totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP $currentStep OF $totalSteps',
          style: AppTextStyles.overline.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(_progress * 100).round()}% Completed',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
