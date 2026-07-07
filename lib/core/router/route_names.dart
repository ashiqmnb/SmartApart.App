/// Central list of all route paths used with GoRouter.
/// Reference these constants instead of typing raw path strings.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';

  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static const String familyMembers = '/family-members';
  static const String addFamilyMember = '/family-members/add';
  static const String editFamilyMember = '/family-members/edit';

  static const String residentDirectory = '/resident-directory';
  static const String residentDetail = '/resident-detail';

  static const String visitorLog = '/visitor-log';
  static const String visitorDetail = '/visitor-detail';
  static const String registerVisitor = '/register-visitor';

  static const String maintenanceList = '/maintenance';
  static const String maintenanceDetail = '/maintenance-detail'; // used as '/maintenance-detail/:id'
  static const String createMaintenance = '/maintenance/create';
  static const String adminMaintenanceDetail = '/admin-maintenance-detail'; // '/admin-maintenance-detail/:id'

  static const String complaintList = '/complaints';
  static const String complaintDetail = '/complaint-detail'; // used as '/complaint-detail/:id'
  static const String submitComplaint = '/complaints/submit';
  static const String adminComplaintDetail = '/admin-complaint-detail'; // '/admin-complaint-detail/:id'

}