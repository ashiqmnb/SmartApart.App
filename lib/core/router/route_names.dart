/// Central list of all route paths used with GoRouter.
/// Reference these constants instead of typing raw path strings.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';

  // ── Resident Shell ──────────────────────────────────────
  static const String residentAnnouncements = '/resident/announcements';
  static const String residentMaintenance = '/resident/maintenance';
  static const String residentComplaints = '/resident/complaints';
  static const String residentVisitors = '/resident/visitors';
  static const String residentProfile = '/resident/profile';

  // ── Security Shell ──────────────────────────────────────
  static const String securityRegisterVisitor = '/security/register-visitor';
  static const String securityVisitorLog = '/security/visitor-log';
  static const String securityProfile = '/security/profile';

  // ── Admin Shell ───────────────────────────────────────────
  static const String adminHome = '/admin/home';
  static const String adminResidents = '/admin/residents';
  static const String adminMaintenance = '/admin/maintenance';
  static const String adminComplaints = '/admin/complaints';
  static const String adminAmenities = '/admin/amenities';
  static const String adminProfile = '/admin/profile';

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

  static const String announcementFeed = '/announcements';
  static const String announcementDetail = '/announcement-detail'; // '/announcement-detail/:id'
  static const String createAnnouncement = '/announcements/create';
  static const String editAnnouncement = '/announcements/edit'; // used as '/announcements/edit/:id'
  static const String adminAnnouncementList = '/admin/announcements';

  static const String amenityList = '/amenities';
  static const String amenityDetail = '/amenity-detail'; // '/amenity-detail/:id'
  static const String createAmenity = '/amenities/create';
  static const String editAmenity = '/amenities/edit'; // '/amenities/edit/:id'

}