import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../storage/secure_storage.dart';
import 'route_names.dart';

// Temporary placeholder screens — real ones arrive in Phase 2.2.
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/home_placeholder_screen.dart';

/// App-wide router config. Similar to createBrowserRouter in React Router —
/// declares path → screen mappings plus a guard that runs before each navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  // Runs before every navigation, like a loader/guard in React Router.
  // Returning null means "no redirect, proceed as requested."
  redirect: (context, state) async {
    final isLoggedIn = await SecureStorage.isLoggedIn();
    final isGoingToAuthScreen = state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register;
    final isGoingToSplash = state.matchedLocation == RouteNames.splash;

    // Let splash screen handle its own routing decision on startup.
    if (isGoingToSplash) return null;

    // Not logged in, trying to reach a protected route → send to login.
    if (!isLoggedIn && !isGoingToAuthScreen) return RouteNames.login;

    // Logged in, but sitting on login/register → send to home.
    if (isLoggedIn && isGoingToAuthScreen) return RouteNames.home;

    return null; // no redirect needed
  },

  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.otpVerification,
      builder: (context, state) {
        // 'extra' arrives as a Map we passed via context.push(..., extra: {...})
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationScreen(
          phoneNumber: extra['phoneNumber'] as String? ?? '',
          purpose: extra['purpose'] as String? ?? 'Registration',
        );
      },
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePlaceholderScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Forgot Password (placeholder)')),
      ),
    ),
  ],
);