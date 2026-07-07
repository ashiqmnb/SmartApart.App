import 'package:go_router/go_router.dart';

import '../../features/amenities/data/models/amenity_models.dart';
import '../../features/amenities/presentation/screens/amenity_detail_screen.dart';
import '../../features/amenities/presentation/screens/amenity_form_screen.dart';
import '../../features/amenities/presentation/screens/amenity_list_screen.dart';
import '../../features/announcements/data/models/announcement_models.dart';
import '../../features/announcements/presentation/screens/admin_announcement_list_screen.dart';
import '../../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../../features/announcements/presentation/screens/announcement_feed_screen.dart';
import '../../features/announcements/presentation/screens/announcement_form_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/complaints/presentation/screens/admin_complaint_detail_screen.dart';
import '../../features/complaints/presentation/screens/complaint_detail_screen.dart';
import '../../features/complaints/presentation/screens/complaint_list_screen.dart';
import '../../features/complaints/presentation/screens/submit_complaint_screen.dart';
import '../../features/maintenance/presentation/screens/admin_maintenance_detail_screen.dart';
import '../../features/maintenance/presentation/screens/create_maintenance_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_detail_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_list_screen.dart';
import '../../features/residents/data/models/family_member_models.dart';
import '../../features/residents/presentation/screens/add_edit_family_member_screen.dart';
import '../../features/residents/presentation/screens/edit_profile_screen.dart';
import '../../features/residents/presentation/screens/family_members_screen.dart';
import '../../features/residents/presentation/screens/profile_screen.dart';
import '../../features/residents/presentation/screens/resident_detail_screen.dart';
import '../../features/residents/presentation/screens/resident_directory_screen.dart';
import '../../features/visitors/presentation/screens/register_visitor_screen.dart';
import '../../features/visitors/presentation/screens/visitor_detail_screen.dart';
import '../../features/visitors/presentation/screens/visitor_log_screen.dart';
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


    GoRoute(
      path: RouteNames.residentDirectory,
      builder: (context, state) => const ResidentDirectoryScreen(),
    ),
    GoRoute(
      path: RouteNames.residentDetail,
      builder: (context, state) {
        final residentId = state.extra as String? ?? '';
        return ResidentDetailScreen(residentId: residentId);
      },
    ),


    GoRoute(
      path: RouteNames.visitorLog,
      builder: (context, state) => const VisitorLogScreen(),
    ),
    GoRoute(
      path: RouteNames.registerVisitor,
      builder: (context, state) => const RegisterVisitorScreen(),
    ),
    GoRoute(
      path: RouteNames.visitorDetail,
      builder: (context, state) {
        final visitorId = state.extra as String? ?? '';
        return VisitorDetailScreen(visitorId: visitorId);
      },
    ),


    GoRoute(
      path: RouteNames.maintenanceList,
      builder: (context, state) => const MaintenanceListScreen(),
    ),
    GoRoute(
      path: '${RouteNames.maintenanceDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaintenanceDetailScreen(requestId: id);
      },
    ),
    GoRoute(
      path: RouteNames.createMaintenance,
      builder: (context, state) => const CreateMaintenanceScreen(),
    ),
    GoRoute(
      path: '${RouteNames.adminMaintenanceDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AdminMaintenanceDetailScreen(requestId: id);
      },
    ),


    GoRoute(
      path: RouteNames.complaintList,
      builder: (context, state) => const ComplaintListScreen(),
    ),
    GoRoute(
      path: '${RouteNames.complaintDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ComplaintDetailScreen(complaintId: id);
      },
    ),
    GoRoute(
      path: RouteNames.submitComplaint,
      builder: (context, state) => const SubmitComplaintScreen(),
    ),
    GoRoute(
      path: '${RouteNames.adminComplaintDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AdminComplaintDetailScreen(complaintId: id);
      },
    ),


    GoRoute(
      path: RouteNames.announcementFeed,
      builder: (context, state) => const AnnouncementFeedScreen(),
    ),
    GoRoute(
      path: '${RouteNames.announcementDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AnnouncementDetailScreen(announcementId: id);
      },
    ),
    GoRoute(
      path: RouteNames.createAnnouncement,
      builder: (context, state) => const AnnouncementFormScreen(),
    ),
    GoRoute(
      path: '${RouteNames.editAnnouncement}/:id',
      builder: (context, state) {
        // Edit mode expects the full AnnouncementDetailModel passed via
        // extra (fetched already by the caller — Step 5's list screen) —
        // avoids a redundant GET call just to open the edit form.
        final announcement = state.extra as AnnouncementDetailModel?;
        return AnnouncementFormScreen(announcement: announcement);
      },
    ),
    GoRoute(
      path: RouteNames.adminAnnouncementList,
      builder: (context, state) => const AdminAnnouncementListScreen(),
    ),


    GoRoute(
      path: RouteNames.amenityList,
      builder: (context, state) => const AmenityListScreen(),
    ),
    GoRoute(
      path: '${RouteNames.amenityDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AmenityDetailScreen(amenityId: id);
      },
    ),
    GoRoute(
      path: RouteNames.createAmenity,
      builder: (context, state) => const AmenityFormScreen(),
    ),
    GoRoute(
      path: '${RouteNames.editAmenity}/:id',
      builder: (context, state) {
        final amenity = state.extra as AmenityDetailModel?;
        return AmenityFormScreen(amenity: amenity);
      },
    ),
  ],
);