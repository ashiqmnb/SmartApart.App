import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';

// Placeholder — real role-based home screens come in Phase 2.7.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (placeholder)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.changePassword),
              child: const Text('Change Password (debug)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.profile),
              child: const Text('Profile (debug)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.residentDirectory),
              child: const Text('Resident Directory (debug)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go(RouteNames.login);
              },
              child: const Text('Logout (debug)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.visitorLog),
              child: const Text('Visitor Log (debug)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.registerVisitor),
              child: const Text('Register Visitor (debug)'),
            ),
          ],
        ),
      ),
    );
  }
}