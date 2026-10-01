import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/profile_card.dart';
import '../../../core/widgets/segmented_tabs.dart';
import 'community_tab.dart';
import 'resources_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _navIndex = 0;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      currentIndex: _navIndex,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == _navIndex) return;
        goToTab(context, index);
      },
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Upload Notes',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: ProfileHeaderCard(
                name: 'Aryan Sharma',
                role: 'Student',
                degree: 'B.Voc Software Development',
                semester: 5,
                college: 'Ramanujan College (DU)',
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedTabsDelegate(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: SegmentedTabs(
                  labels: const ['Community', 'Resources'],
                  selectedIndex: _tabIndex,
                  onChanged: (index) => setState(() => _tabIndex = index),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: _tabIndex == 0
                  ? const CommunityTab()
                  : const ResourcesTab(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps [child] (the segmented tabs) pinned to the top of the
/// CustomScrollView once the profile card above it has scrolled away.
class _PinnedTabsDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabsDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: AppColors.background, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabsDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
