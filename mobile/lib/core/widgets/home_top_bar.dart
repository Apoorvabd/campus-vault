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
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final TextEditingController? searchController;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
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
            icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 30),
            onPressed: onMenuTap,
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
          style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search notes, PYQs...',
            hintStyle: const TextStyle(fontSize: 16, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),

      actions: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          ),
          margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md),
          child: IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.textPrimary, size: 28),
            onPressed: onNotificationsTap,
          ),
        ),
       
      ],
    );
  }
}
