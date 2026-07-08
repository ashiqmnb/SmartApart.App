import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Admin profile access lives here rather than as a bottom-nav
          // tab, per the Step 1 decision.
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(RouteNames.profile),
          ),
        ],
      ),
      body: Consumer<AdminDashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.summary == null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final summary = provider.summary;
          if (summary == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => provider.fetchSummary(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCountsGrid(summary),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentSection(
                  title: 'Recent Maintenance Requests',
                  items: summary.recentMaintenance,
                  emptyLabel: 'No open maintenance requests.',
                  onSeeAll: () => context.go(RouteNames.adminMaintenance),
                ),
                const SizedBox(height: 24),
                _buildRecentSection(
                  title: 'Recent Complaints',
                  items: summary.recentComplaints,
                  emptyLabel: 'No pending complaints.',
                  onSeeAll: () => context.go(RouteNames.adminComplaints),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountsGrid(dynamic summary) {
    final cards = [
      _CountCardData('Residents', summary.totalResidents, Icons.people_outline, Colors.blue),
      _CountCardData('Open Requests', summary.openMaintenanceCount, Icons.build_outlined, Colors.orange),
      _CountCardData('Pending Complaints', summary.pendingComplaintsCount, Icons.report_outlined, Colors.red),
      _CountCardData('Scheduled Notices', summary.upcomingAnnouncementsCount, Icons.campaign_outlined, Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards.map((c) => _CountCard(data: c)).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('New Notice'),
            onPressed: () => context.push(RouteNames.createAnnouncement),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.pool_outlined),
            label: const Text('New Amenity'),
            onPressed: () => context.push(RouteNames.createAmenity),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection({
    required String title,
    required List<dynamic> items,
    required String emptyLabel,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(emptyLabel, style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...items.take(5).map((item) => _buildRecentTile(item)),
      ],
    );
  }

  // ⚠️ Field access here is defensive since the item type is `dynamic`
  // (see model note above). Replace `item.title` / `item.status` with
  // your actual MaintenanceListModel / ComplaintListModel field names
  // once confirmed — flutter analyze will flag any mismatch.
  Widget _buildRecentTile(dynamic item) {
    String title = 'Item';
    String subtitle = '';
    try {
      title = item.title ?? 'Untitled';
      subtitle = item.status ?? '';
    } catch (_) {}

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.circle, size: 8),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _CountCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  _CountCardData(this.label, this.value, this.icon, this.color);
}

class _CountCard extends StatelessWidget {
  final _CountCardData data;
  const _CountCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(data.icon, color: data.color),
            Text('${data.value}', style: Theme.of(context).textTheme.headlineSmall),
            Text(data.label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}