import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Top bar used on Home/Resources-style screens: hamburger menu,
/// a wide inline search field, and a notification bell.
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({
    super.key,
    this.onMenuTap,
    this.onSearchTap,
    this.onNotificationsTap,
    this.searchController,
    this.readOnly = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.showBackButton = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final TextEditingController? searchController;

  /// When true (default) the search field just opens [SearchScreen] on tap
  /// (used on Home). Set to false to let this bar's own field be typed in
  /// directly (used on the Search screen itself).
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Shows a back arrow instead of the hamburger menu — for screens that
  /// were pushed on top of Home (e.g. Search) rather than being a root tab.
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 58,
      leadingWidth: 60,
      elevation: 2,
      titleSpacing: 0,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0),
      leading: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
          ),
          child: IconButton(
            icon: Icon(
              showBackButton ? Icons.arrow_back : Icons.menu,
              color: AppColors.textPrimary,
              size: showBackButton ? 26 : 30,
            ),
            onPressed: showBackButton
                ? () => Navigator.maybePop(context)
                : onMenuTap,
          ),
        ),
      ),

      title: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: const Color.fromARGB(255, 154, 151, 151)),
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
        ),
        child: TextField(
          controller: searchController,
          readOnly: readOnly,
          autofocus: autofocus,
          onTap: onSearchTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search notes, PYQs...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 20,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),

      actions: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,

            borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          ),
          margin: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: onNotificationsTap,
          ),
        ),
      ],
    );
  }
}
