import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';

/// Admin-only screen — status updater + resolution note.
/// No staff assignment for complaints (only Maintenance has that
/// workflow per the backend), so this is simpler than its Maintenance
/// counterpart.
class AdminComplaintDetailScreen extends StatefulWidget {
  final String complaintId;
  const AdminComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<AdminComplaintDetailScreen> createState() => _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState extends State<AdminComplaintDetailScreen> {
  static const _statuses = ['Pending', 'UnderReview', 'Resolved', 'Closed'];

  String? _selectedStatus;
  final _resolutionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ComplaintProvider>();
      if (provider.selectedComplaint == null) {
        await provider.fetchDetail(widget.complaintId);
      }
      if (mounted) {
        setState(() {
          _selectedStatus = provider.selectedComplaint?.status;
          _resolutionController.text = provider.selectedComplaint?.resolutionNote ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateStatus() async {
    if (_selectedStatus == null) return;
    final provider = context.read<ComplaintProvider>();
    final success = await provider.updateStatus(
      widget.complaintId,
      _selectedStatus!,
      resolutionNote: _resolutionController.text.trim().isEmpty
          ? null
          : _resolutionController.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Complaint')),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          final complaint = provider.selectedComplaint;
          if (provider.isDetailLoading || complaint == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAnonymous = complaint.complaintType == 'Anonymous';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(complaint.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('${complaint.category} · Reported by: ${complaint.reporterName}'),
                if (isAnonymous) ...[
                  const SizedBox(height: 4),
                  Text(
                    'This complaint was submitted anonymously.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),

                Text('Update Status', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _resolutionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Resolution Note (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),

                if (provider.errorMessage != null) ...[
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: provider.isSubmitting ? null : _handleUpdateStatus,
                  child: provider.isSubmitting
                      ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Update Status'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}