import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../providers/maintenance_provider.dart';

/// Admin-only screen — assign staff + update status + resolution note.
/// Reuses MaintenanceProvider.selectedRequest (already fetched by the
/// time this screen is pushed from MaintenanceDetailScreen).
class AdminMaintenanceDetailScreen extends StatefulWidget {
  final String requestId;
  const AdminMaintenanceDetailScreen({super.key, required this.requestId});

  @override
  State<AdminMaintenanceDetailScreen> createState() => _AdminMaintenanceDetailScreenState();
}

class _AdminMaintenanceDetailScreenState extends State<AdminMaintenanceDetailScreen> {
  static const _statuses = ['Open', 'Assigned', 'InProgress', 'Completed', 'Cancelled'];

  String? _selectedStatus;
  final _resolutionController = TextEditingController();

  // Lightweight staff list — fetched directly here since there's no
  // dedicated staff directory/provider yet.
  List<_StaffOption> _staffOptions = [];
  bool _staffLoading = true;
  String? _selectedStaffId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MaintenanceProvider>();
      if (provider.selectedRequest == null) {
        await provider.fetchDetail(widget.requestId);
      }
      if (mounted) {
        setState(() {
          _selectedStatus = provider.selectedRequest?.status;
          _resolutionController.text = provider.selectedRequest?.resolutionNote ?? '';
        });
      }
      _fetchStaff();
    });
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _fetchStaff() async {
    try {
      final response = await DioClient.instance.get('/users', queryParameters: {
        'role': 'Security',
        'pageSize': 100,
      });
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
      final items = (apiResponse.data?['items'] as List? ?? []);
      setState(() {
        _staffOptions = items
            .map((u) => _StaffOption(id: u['id'], name: u['fullName'] ?? 'Unnamed'))
            .toList();
        _staffLoading = false;
      });
    } catch (_) {
      setState(() => _staffLoading = false);
    }
  }

  Future<void> _handleAssign() async {
    if (_selectedStaffId == null) return;
    final provider = context.read<MaintenanceProvider>();
    final success = await provider.assignRequest(widget.requestId, _selectedStaffId!);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request assigned successfully.')),
      );
    }
  }

  Future<void> _handleUpdateStatus() async {
    if (_selectedStatus == null) return;
    final provider = context.read<MaintenanceProvider>();
    final success = await provider.updateStatus(
      widget.requestId,
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
      appBar: AppBar(title: const Text('Manage Maintenance Request')),
      body: Consumer<MaintenanceProvider>(
        builder: (context, provider, _) {
          final request = provider.selectedRequest;
          if (provider.isDetailLoading || request == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(request.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('${request.category} · ${request.priority} priority · Current: ${request.status}'),
                const SizedBox(height: 24),

                // ── Assign to Staff ──────────────────────────────
                Text('Assign to Staff', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (_staffLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_staffOptions.isEmpty)
                  const Text('No Security staff found.', style: TextStyle(color: Colors.grey))
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStaffId,
                    decoration: const InputDecoration(labelText: 'Select staff member'),
                    items: _staffOptions
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStaffId = v),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: (_selectedStaffId == null || provider.isSubmitting)
                      ? null
                      : _handleAssign,
                  child: provider.isSubmitting
                      ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Assign'),
                ),
                const Divider(height: 40),

                // ── Update Status ────────────────────────────────
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

class _StaffOption {
  final String id;
  final String name;
  _StaffOption({required this.id, required this.name});
}