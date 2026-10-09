import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Labeled text field matching the Sign In / Signup form inputs.
/// Supports an optional trailing label next to the field's own label
/// (e.g. "Password" + "Forgot password?") and an optional suffix icon
/// (eye toggle, checkmark, search icon).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.trailingLabel,
    this.onTrailingLabelTap,
    this.keyboardType,
    this.compact = true,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? trailingLabel;
  final VoidCallback? onTrailingLabelTap;
  final TextInputType? keyboardType;

  /// Shorter field with tighter padding (used on the Sign In card).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
            ),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingLabelTap,
                child: Text(
                  trailingLabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.bodySemiBold.copyWith(
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            isDense: compact,
            contentPadding: compact
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                : null,
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    visualDensity: compact ? VisualDensity.compact : null,
                    onPressed: onSuffixTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
