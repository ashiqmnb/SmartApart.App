import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/maintenance_models.dart';
import '../providers/maintenance_provider.dart';

/// Lists maintenance requests with status + category filter chips.
/// Same infinite-scroll pattern as VisitorLogScreen — a ScrollController
/// listener triggers fetchMore() near the bottom of the list.
class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _scrollController = ScrollController();
  String? _selectedStatus;
  String? _selectedCategory;

  static const _statuses = ['Open', 'Assigned', 'InProgress', 'Completed', 'Cancelled'];
  static const _categories = [
    'Plumbing',
    'Electrical',
    'WaterLeakage',
    'LiftIssues',
    'Cleaning',
    'General',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch after first frame — same reasoning as VisitorLogScreen:
    // avoids calling notifyListeners() during the initial build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().fetchRequests();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MaintenanceProvider>().fetchMore();
    }
  }

  void _applyFilters() {
    context.read<MaintenanceProvider>().fetchRequests(
      status: _selectedStatus,
      category: _selectedCategory,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blueGrey;
      case 'Assigned':
        return Colors.orange;
      case 'InProgress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Requests')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<MaintenanceProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.requests.isEmpty) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.requests.isEmpty) {
                  return const Center(child: Text('No maintenance requests found.'));
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchRequests(
                    status: _selectedStatus,
                    category: _selectedCategory,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.requests.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.requests.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildCard(provider.requests[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.createMaintenance),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildDropdownChip(
            label: 'Status',
            value: _selectedStatus,
            options: _statuses,
            onChanged: (v) {
              setState(() => _selectedStatus = v);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _buildDropdownChip(
            label: 'Category',
            value: _selectedCategory,
            options: _categories,
            onChanged: (v) {
              setState(() => _selectedCategory = v);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return InputChip(
      label: Text(value ?? label),
      selected: value != null,
      onPressed: () async {
        final selected = await showModalBottomSheet<String?>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('All $label'),
                  onTap: () => Navigator.pop(context, null),
                ),
                ...options.map((o) => ListTile(
                  title: Text(o),
                  onTap: () => Navigator.pop(context, o),
                )),
              ],
            ),
          ),
        );
        onChanged(selected);
      },
      onDeleted: value != null ? () => onChanged(null) : null,
    );
  }

  Widget _buildCard(MaintenanceListModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => context.push('${RouteNames.maintenanceDetail}/${request.id}'),
        leading: CircleAvatar(
          backgroundColor: _statusColor(request.status).withValues(alpha: 0.15),
          child: Icon(Icons.build, color: _statusColor(request.status)),
        ),
        title: Text(request.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${request.category} · ${request.priority}'),
        trailing: Chip(
          label: Text(request.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor(request.status).withValues(alpha: 0.15),
          labelStyle: TextStyle(color: _statusColor(request.status)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}