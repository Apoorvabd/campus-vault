import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, outline, small }

/// Single button widget covering every button style seen in the designs:
/// full-width primary pill, outline (e.g. Google SSO), and small pill
/// (e.g. Preview / View PDF actions inside a card).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.radius,
    this.fontSize,
    this.textColor,
    this.verticalPadding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Whether the button should stretch to fill its parent's width.
  /// Small pill buttons inside cards usually pass `false`.
  final bool expand;
  final double? radius;
  final double? fontSize;
  final Color? textColor;   // ← naya
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Text(
          label,
          style: (fontSize != null || textColor != null)
              ? AppTextStyles.buttonText.copyWith(
            fontSize: fontSize,
            color: textColor ??
                (variant == AppButtonVariant.outline
                    ? AppColors.textPrimary
                    : Colors.white),
          )
              : null,
        ),
        const SizedBox(width:12),
        if (icon != null) ...[
          Icon(icon, size: variant == AppButtonVariant.small ? 16 : 26),
          const SizedBox(width: 8),
        ],

      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
    onPressed: onPressed,
    style: (radius != null || verticalPadding != null)
        ? ElevatedButton.styleFrom(
            shape: radius != null
                ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                : null,
            padding: verticalPadding != null
                ? EdgeInsets.symmetric(horizontal: 20, vertical: verticalPadding!)
                : null,
          )
        : null,
    child: child,
  ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: onPressed,

          child: child,
        ),
      AppButtonVariant.small => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.buttonText.copyWith(fontSize: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              // borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: child,
        ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
