import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/complaint_models.dart';
import '../providers/complaint_provider.dart';

/// Lists complaints with status filter tabs. Anonymous complaints
/// show an "Anonymous" label instead of the reporter's name — the
/// backend already masks residentId/reporterName, so this screen
/// just displays whatever comes back without extra logic.
class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  static const _statuses = [null, 'Pending', 'UnderReview', 'Resolved', 'Closed'];
  static const _tabLabels = ['All', 'Pending', 'Under Review', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().fetchComplaints();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<ComplaintProvider>().fetchComplaints(
      status: _statuses[_tabController.index],
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ComplaintProvider>().fetchMore();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'UnderReview':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.complaints.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.complaints.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchComplaints(
              status: _statuses[_tabController.index],
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: provider.complaints.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.complaints.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildCard(provider.complaints[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.submitComplaint),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(ComplaintListModel complaint) {
    final isAnonymous = complaint.complaintType == 'Anonymous';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => context.push('${RouteNames.complaintDetail}/${complaint.id}'),
        leading: CircleAvatar(
          backgroundColor: _statusColor(complaint.status).withValues(alpha: 0.15),
          child: Icon(
            isAnonymous ? Icons.visibility_off_outlined : Icons.report_problem_outlined,
            color: _statusColor(complaint.status),
          ),
        ),
        title: Text(complaint.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(complaint.category),
            if (isAnonymous) ...[
              const SizedBox(width: 6),
              const Chip(
                label: Text('Anonymous', style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(complaint.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor(complaint.status).withValues(alpha: 0.15),
          labelStyle: TextStyle(color: _statusColor(complaint.status)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}