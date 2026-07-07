import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../providers/complaint_provider.dart';

/// Detail view — category, type badge (Normal/Anonymous), description,
/// images, status, resolution note. Admin gets a "Manage" button
/// (wired to AdminComplaintDetailScreen in Step 7), gated by role.
class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().fetchDetail(widget.complaintId);
    });
  }

  @override
  void dispose() {
    context.read<ComplaintProvider>().clearSelectedComplaint();
    super.dispose();
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
    final role = context.watch<ProfileProvider>().profile?.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaint = provider.selectedComplaint;
          if (complaint == null) {
            return Center(child: Text(provider.errorMessage ?? 'Complaint not found.'));
          }

          final isAnonymous = complaint.complaintType == 'Anonymous';

          return RefreshIndicator(
            onRefresh: () => provider.fetchDetail(widget.complaintId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        complaint.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Chip(
                      label: Text(complaint.status),
                      backgroundColor: _statusColor(complaint.status).withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: _statusColor(complaint.status)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(complaint.category, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        isAnonymous ? 'Anonymous' : 'Normal',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor:
                      isAnonymous ? Colors.grey.shade300 : Colors.blue.shade50,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Description', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(complaint.description),
                const SizedBox(height: 20),

                if (complaint.images.isNotEmpty) ...[
                  Text('Photos', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: complaint.images.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final img = complaint.images[index];
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

                if (complaint.resolutionNote != null) ...[
                  Text('Resolution Note', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(complaint.resolutionNote!),
                  const SizedBox(height: 20),
                ],

                _infoRow('Reported by', complaint.reporterName),
                const SizedBox(height: 24),

                // Admin: manage button — wired to AdminComplaintDetailScreen in Step 7.
                if (role == 'Admin')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Manage Complaint'),
                    onPressed: () => context.push('${RouteNames.adminComplaintDetail}/${complaint.id}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}