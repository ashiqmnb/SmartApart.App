import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/role_scaffold.dart';

class ResidentShellScreen extends StatelessWidget {
  final Widget child;
  const ResidentShellScreen({super.key, required this.child});

  static const _tabs = [
    NavTabConfig(
      label: 'Notices',
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign,
      route: RouteNames.residentAnnouncements,
    ),
    NavTabConfig(
      label: 'Maintenance',
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      route: RouteNames.residentMaintenance,
    ),
    NavTabConfig(
      label: 'Complaints',
      icon: Icons.report_outlined,
      activeIcon: Icons.report,
      route: RouteNames.residentComplaints,
    ),
    NavTabConfig(
      label: 'Visitors',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: RouteNames.residentVisitors,
    ),
    NavTabConfig(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: RouteNames.residentProfile,
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