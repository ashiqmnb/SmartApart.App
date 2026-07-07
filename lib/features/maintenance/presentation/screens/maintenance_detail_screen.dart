import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../providers/maintenance_provider.dart';

/// Detail view with a horizontal status timeline (Open → Assigned →
/// InProgress → Completed), image gallery, and resolution note.
/// Admin gets an extra "Manage" button routed to AdminMaintenanceDetailScreen
/// (built in Step 7) — gated by ProfileProvider.profile?.role, same
/// pattern as VisitorDetailScreen.
class MaintenanceDetailScreen extends StatefulWidget {
  final String requestId;
  const MaintenanceDetailScreen({super.key, required this.requestId});

  @override
  State<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  static const _timelineSteps = ['Open', 'Assigned', 'InProgress', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().fetchDetail(widget.requestId);
    });
  }

  @override
  void dispose() {
    // Clear so the next screen doesn't briefly show stale data.
    context.read<MaintenanceProvider>().clearSelectedRequest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ProfileProvider>().profile?.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: Consumer<MaintenanceProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final request = provider.selectedRequest;
          if (request == null) {
            return Center(child: Text(provider.errorMessage ?? 'Request not found.'));
          }

          final isCancelled = request.status == 'Cancelled';

          return RefreshIndicator(
            onRefresh: () => provider.fetchDetail(widget.requestId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(request.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  '${request.category} · ${request.priority} priority',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                if (!isCancelled) _buildTimeline(request.status),
                if (isCancelled)
                  const Chip(
                    label: Text('Cancelled'),
                    backgroundColor: Color(0xFFFFE0E0),
                  ),
                const SizedBox(height: 20),

                Text('Description', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(request.description),
                const SizedBox(height: 20),

                if (request.images.isNotEmpty) ...[
                  Text('Photos', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: request.images.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final img = request.images[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            img.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (request.assignedToName != null) ...[
                  _infoRow('Assigned to', request.assignedToName!),
                  const SizedBox(height: 8),
                ],

                if (request.resolutionNote != null) ...[
                  Text('Resolution Note', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(request.resolutionNote!),
                  const SizedBox(height: 20),
                ],

                _infoRow('Raised by', request.residentName),
                _infoRow('Unit', '${request.block} - ${request.apartmentNumber}'),
                const SizedBox(height: 24),

                // Resident: cancel own Open request only.
                if (role == 'Resident' && request.status == 'Open')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel Request'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _confirmCancel(context, provider),
                  ),

                // Admin: manage button — wired to AdminMaintenanceDetailScreen in Step 7.
                if (role == 'Admin')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Manage Request'),
                    onPressed: () => context.push('${RouteNames.adminMaintenanceDetail}/${request.id}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final currentIndex = _timelineSteps.indexOf(currentStatus);

    return Row(
      children: List.generate(_timelineSteps.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == _timelineSteps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timelineSteps[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, MaintenanceProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('This will cancel your maintenance request.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.cancelRequest(widget.requestId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request cancelled.')),
        );
      }
    }
  }
}