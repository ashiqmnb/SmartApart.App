import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final isLoggedIn = await SecureStorage.isLoggedIn();

    if (!isLoggedIn) {
      if (mounted) context.go(RouteNames.login);
      return;
    }

    final role = await SecureStorage.getRole();
    if (!mounted) return;

    switch (role) {
      case 'Admin':
        context.go(RouteNames.adminHome);
        break;
      case 'Security':
        context.go(RouteNames.securityRegisterVisitor);
        break;
      case 'Resident':
        context.go(RouteNames.residentAnnouncements);
        break;
      default:
        _handleUnknownRole();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _handleUnknownRole() async {
    await SecureStorage.clearAll();
    if (!mounted) return;
    context.go(RouteNames.login);
  }
}