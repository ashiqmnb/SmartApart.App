import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/residents/data/models/family_member_models.dart';
import '../../features/residents/presentation/screens/add_edit_family_member_screen.dart';
import '../../features/residents/presentation/screens/edit_profile_screen.dart';
import '../../features/residents/presentation/screens/family_members_screen.dart';
import '../../features/residents/presentation/screens/profile_screen.dart';
import '../storage/secure_storage.dart';
import 'route_names.dart';

// Temporary placeholder screens — real ones arrive in Phase 2.2.
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/home_placeholder_screen.dart';

/// App-wide router config. Similar to createBrowserRouter in React Router —
/// declares path → screen mappings plus a guard that runs before each navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  // Runs before every navigation, like a loader/guard in React Router.
  // Returning null means "no redirect, proceed as requested."
  redirect: (context, state) async {
    final isLoggedIn = await SecureStorage.isLoggedIn();

    final publicRoutes = [
      RouteNames.login,
      RouteNames.forgotPassword,
      RouteNames.resetPassword,
    ];
    final isGoingToPublicRoute = publicRoutes.contains(state.matchedLocation);
    final isGoingToSplash = state.matchedLocation == RouteNames.splash;

    // Let splash screen handle its own routing decision on startup.
    if (isGoingToSplash) return null;

    // Not logged in, trying to reach a protected route → send to login.
    if (!isLoggedIn && !isGoingToPublicRoute) return RouteNames.login;

    // Logged in, but sitting on login → send to home.
    // (Forgot/Reset Password should stay reachable even if technically
    // logged in, e.g. testing flows — but typically only Login redirects away.)
    if (isLoggedIn && state.matchedLocation == RouteNames.login) {
      return RouteNames.home;
    }

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
      path: RouteNames.home,
      builder: (context, state) => const HomePlaceholderScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      builder: (context, state) {
        // state.extra carries whatever we passed via context.push(path, extra: ...)
        final phone = state.extra as String? ?? '';
        return ResetPasswordScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: RouteNames.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),


    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),


    GoRoute(
      path: RouteNames.familyMembers,
      builder: (context, state) => const FamilyMembersScreen(),
    ),
    GoRoute(
      path: RouteNames.addFamilyMember,
      builder: (context, state) => const AddEditFamilyMemberScreen(),
    ),
    GoRoute(
      path: RouteNames.editFamilyMember,
      builder: (context, state) {
        // extra carries the full FamilyMemberModel passed from
        // FamilyMembersScreen's onTap (context.push(path, extra: member)).
        final member = state.extra as FamilyMemberModel?;
        return AddEditFamilyMemberScreen(existingMember: member);
      },
    ),
  ],
);