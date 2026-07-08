/// Aggregated counts + recent items for the Admin dashboard.
/// Built client-side from multiple endpoint calls (no single backend
/// dashboard endpoint exists yet — this composes existing list APIs).
class AdminDashboardSummary {
  final int totalResidents;
  final int openMaintenanceCount;
  final int pendingComplaintsCount;
  final int upcomingAnnouncementsCount;
  final List<dynamic> recentMaintenance; // MaintenanceListModel items
  final List<dynamic> recentComplaints; // ComplaintListModel items

  AdminDashboardSummary({
    required this.totalResidents,
    required this.openMaintenanceCount,
    required this.pendingComplaintsCount,
    required this.upcomingAnnouncementsCount,
    required this.recentMaintenance,
    required this.recentComplaints,
  });
}