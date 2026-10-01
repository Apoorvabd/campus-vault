import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'home_top_bar.dart';

/// Shared shell used by every main tab screen (Home, Saved, Profile) —
/// same [HomeTopBar] + [AppBottomNavBar] everywhere, only [body] changes.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
    required this.body,
    this.onSearchTap,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;
  final VoidCallback? onSearchTap;
  final Widget? floatingActionButton;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(
        onSearchTap: onSearchTap,
        showBackButton: showBackButton,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
