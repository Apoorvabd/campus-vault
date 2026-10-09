import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.note,
  });

  final IconData icon; // outlined, when not selected
  final IconData activeIcon; // filled, when selected
  final String label;
  final String? note; // tiny line under the label, e.g. "Coming soon"
}

/// The single, unified 5-item bottom nav: Home / Exam Mode / Add / Saved /
/// Profile. The middle "Add" slot is a raised accent button; the others show
/// a filled blue icon when selected and a black outlined one otherwise.
/// Do not introduce other item sets — see docs/design-system.html notes.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const addIndex = 2;

  static const items = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'Exam Mode',
      note: 'Coming soon',
    ),
    BottomNavItem(
      icon: Icons.add_rounded,
      activeIcon: Icons.add_rounded,
      label: 'Add',
    ),
    BottomNavItem(
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Saved',
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: i == addIndex
                      ? _AddButton(onTap: () => onTap(i))
                      : _NavItem(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? item.activeIcon : item.icon,
            size: 24,
            color: color,
            // soft drop shadow so the icon looks lifted off the bar
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
          if (item.note != null)
            Text(
              item.note!,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 8,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// The raised accent "+" button in the middle of the bar.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
