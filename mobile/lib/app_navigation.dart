import 'package:flutter/material.dart';
import 'core/navigation/tab_shell.dart';
import 'features/search/presentation/search_screen.dart';

/// Switches the bottom-nav tab (Exam Mode isn't built yet, so index 1 no-ops).
/// Inside the shell it just changes the tab. From a screen pushed on top of
/// the shell (e.g. Subject Detail) it first closes back to the shell.
void goToTab(BuildContext context, int index) {
  if (index == 1) return;
  mainTabIndex.value = index;
  if (!TabShellScope.isInside(context)) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Opens the Search screen with a fast fade so the keyboard feels instant.
void openSearch(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 120),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SearchScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
