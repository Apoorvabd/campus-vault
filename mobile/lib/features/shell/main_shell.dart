import 'package:flutter/material.dart';
import '../../app_navigation.dart';
import '../../core/navigation/tab_shell.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/home_top_bar.dart';
import '../home/presentation/homescreen.dart';
import '../profile/presentation/profile_screen.dart';
import '../saved/presentation/saved_screen.dart';
import '../upload/presentation/create_document_screen.dart';

/// The one screen that owns the top bar and the bottom nav. The tabs live
/// inside it, so switching tabs only swaps the body (with a short fade): the
/// bars never rebuild or slide, and every tab keeps its state and scroll.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  // A tab is built the first time it is opened, not all at app start
  final _visited = <int>{};

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: 1,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.3,
    end: 1,
  ).animate(CurvedAnimation(parent: _fade, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    mainTabIndex.value = 0; // a fresh login always starts on Home
    _visited.add(0);
    mainTabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_onTabChanged);
    _fade.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() => _visited.add(mainTabIndex.value));
    _fade.forward(from: 0);
  }

  Widget _tab(int index) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return switch (index) {
      0 => const HomeScreen(),
      2 => const CreateDocumentScreen(),
      3 => const SavedScreen(),
      4 => const ProfileScreen(),
      _ => const SizedBox.shrink(), // Exam Mode isn't built yet
    };
  }

  @override
  Widget build(BuildContext context) {
    final index = mainTabIndex.value;
    return Scaffold(
      appBar: HomeTopBar(onSearchTap: () => openSearch(context)),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: index,
        onTap: (i) => goToTab(context, i),
      ),
      body: TabShellScope(
        child: FadeTransition(
          opacity: _opacity,
          child: IndexedStack(
            index: index,
            children: [for (var i = 0; i < 5; i++) _tab(i)],
          ),
        ),
      ),
    );
  }
}
