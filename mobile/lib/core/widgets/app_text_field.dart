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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 17)),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingLabelTap,
                child: Text(
                  trailingLabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.bodySemiBold.copyWith(fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppColors.textMuted, size: 20),
                    onPressed: onSuffixTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
