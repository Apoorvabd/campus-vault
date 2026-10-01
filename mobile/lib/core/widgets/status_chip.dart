import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum StatusChipVariant { pyq, notes, verified, labManual, syllabus, reference }

/// Small pill badge — "PYQ" / "NOTES" filled chips, or the outlined
/// "✓ Verified" / "100% Solved" chip.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.variant});

  final String label;
  final StatusChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Border? border) = switch (variant) {
      StatusChipVariant.pyq => (
        AppColors.primaryLight,
        AppColors.primary,
        null,
      ),
      StatusChipVariant.notes => (
        AppColors.accentPurple.withValues(alpha: 0.12),
        AppColors.accentPurple,
        null,
      ),
      StatusChipVariant.verified => (
        AppColors.success.withValues(alpha: 0.08),
        AppColors.success,
        Border.all(color: AppColors.success),
      ),
      StatusChipVariant.labManual => (
        AppColors.accentPink.withValues(alpha: 0.12),
        AppColors.accentPink,
        null,
      ),
      StatusChipVariant.syllabus => (
        AppColors.accentTeal.withValues(alpha: 0.12),
        AppColors.accentTeal,
        null,
      ),
      StatusChipVariant.reference => (
        AppColors.accentOrange.withValues(alpha: 0.12),
        AppColors.accentOrange,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
