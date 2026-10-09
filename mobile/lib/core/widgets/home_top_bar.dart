import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_logo.dart';

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
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      leadingWidth: 64,
      elevation: 2,
      titleSpacing: 0,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0),
      // Root tabs show the brand mark (the old hamburger had no menu behind
      // it); pushed screens such as Search keep the back arrow.
      leading: !showBackButton && onMenuTap == null
          ? const Center(child: AppLogo.mark(height: 38))
          : Center(
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
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search notes, PYQs...',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 38,
            ),
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
            // Smaller bell and tap area, so the logo and search get the room
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            icon: const Icon(
              Icons.notifications,
              color: AppColors.textPrimary,
            ),
            onPressed: onNotificationsTap,
          ),
        ),
      ],
    );
  }
}
