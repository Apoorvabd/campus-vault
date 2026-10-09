import 'package:flutter/widgets.dart';

/// Which bottom-nav tab is showing (0 Home, 2 Add, 3 Saved, 4 Profile).
/// MainShell listens to it; anything can change it through goToTab().
final mainTabIndex = ValueNotifier<int>(0);

/// Placed by MainShell above its tabs. A screen that finds it knows the top
/// bar and bottom nav already exist, so it must only draw its own body.
class TabShellScope extends InheritedWidget {
  const TabShellScope({super.key, required super.child});

  static bool isInside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabShellScope>() != null;

  @override
  bool updateShouldNotify(TabShellScope oldWidget) => false;
}
