import 'package:flutter/material.dart';
import 'features/home/presentation/homescreen.dart';
import 'features/saved/presentation/saved_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/upload/presentation/create_document_screen.dart';

/// Switches between the bottom-nav tabs that are wired up so far
/// (Exam Mode isn't built yet, so that index no-ops).
void goToTab(BuildContext context, int index) {
  final Widget? screen = switch (index) {
    0 => const HomeScreen(),
    2 => const CreateDocumentScreen(),
    3 => const SavedScreen(),
    4 => const ProfileScreen(),
    _ => null,
  };
  if (screen == null) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
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
