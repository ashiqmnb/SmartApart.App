import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/role_scaffold.dart';

class SecurityShellScreen extends StatelessWidget {
  final Widget child;
  const SecurityShellScreen({super.key, required this.child});

  static const _tabs = [
    NavTabConfig(
      label: 'Register',
      icon: Icons.person_add_alt_outlined,
      activeIcon: Icons.person_add_alt,
      route: RouteNames.securityRegisterVisitor,
    ),
    NavTabConfig(
      label: 'Visitor Log',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      route: RouteNames.securityVisitorLog,
    ),
    NavTabConfig(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: RouteNames.securityProfile,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.route));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      tabs: _tabs,
      currentIndex: _currentIndex(context),
      onTabSelected: (index) => context.go(_tabs[index].route),
      child: child,
    );
  }
}