import 'package:flutter/material.dart';

/// Config for a single bottom-nav tab.
class NavTabConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavTabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Shared scaffold used by all three role shells. Renders the current
/// shell page (passed in by GoRouter's ShellRoute as `child`) plus a
/// BottomNavigationBar built from `tabs`. Tapping a tab navigates via
/// GoRouter — same idea as a `NavLink` list in a React layout component.
class RoleScaffold extends StatelessWidget {
  final Widget child;
  final List<NavTabConfig> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const RoleScaffold({
    super.key,
    required this.child,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabSelected,
        destinations: tabs
            .map((tab) => NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.activeIcon),
          label: tab.label,
        ))
            .toList(),
      ),
    );
  }
}