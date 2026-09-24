import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BottomNavItem {
  const BottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// The single, unified 5-item bottom nav: Home / Subjects / Requests / Saved / Profile.
/// Do not introduce other item sets — see docs/design-system.html notes.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = [
    BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.menu_book_rounded, label: 'Subjects'),
    BottomNavItem(icon: Icons.help_outline_rounded, label: 'Requests'),
    BottomNavItem(icon: Icons.bookmark_border_rounded, label: 'Saved'),
    BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
