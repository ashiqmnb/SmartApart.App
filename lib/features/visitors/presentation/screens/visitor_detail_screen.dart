import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../data/models/visitor_models.dart';
import '../providers/visitor_provider.dart';

class VisitorDetailScreen extends StatefulWidget {
  final String visitorId;
  const VisitorDetailScreen({super.key, required this.visitorId});

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorProvider>().fetchVisitorDetail(widget.visitorId);
    });
  }

  Future<void> _handleApprove() async {
    final provider = context.read<VisitorProvider>();
    final success = await provider.approveVisitor(widget.visitorId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Visitor approved.' : (provider.detailErrorMessage ?? 'Failed to approve.'))),
    );
  }

  Future<void> _handleReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Visitor'),
        content: const Text('Are you sure you want to reject this visitor?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<VisitorProvider>();
    final success = await provider.rejectVisitor(widget.visitorId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Visitor rejected.' : (provider.detailErrorMessage ?? 'Failed to reject.'))),
    );
  }

  Future<void> _handleExit() async {
    final provider = context.read<VisitorProvider>();
    final success = await provider.registerExit(widget.visitorId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Exit recorded.' : (provider.detailErrorMessage ?? 'Failed to record exit.'))),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Detail')),
      body: SafeArea(
        child: Consumer<VisitorProvider>(
          builder: (context, provider, _) {
            if (provider.isDetailLoading && provider.selectedVisitor == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final visitor = provider.selectedVisitor;
            if (visitor == null) {
              return Center(child: Text(provider.detailErrorMessage ?? 'Visitor not found.'));
            }

            final role = context.watch<ProfileProvider>().profile?.role;
            final statusColor = _statusColor(visitor.approvalStatus);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: statusColor.withValues(alpha: 0.15),
                        child: Icon(Icons.person_outline, size: 36, color: statusColor),
                      ),
                      const SizedBox(height: 12),
                      Text(visitor.visitorName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          visitor.approvalStatus,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row(Icons.phone_outlined, 'Phone', visitor.visitorPhone),
                        const Divider(height: 24),
                        _Row(Icons.info_outline, 'Purpose', visitor.purpose),
                        if (visitor.vehicleNumber != null) ...[
                          const Divider(height: 24),
                          _Row(Icons.directions_car_outlined, 'Vehicle', visitor.vehicleNumber!),
                        ],
                        const Divider(height: 24),
                        _Row(Icons.person_pin_outlined, 'Visiting', '${visitor.residentName} (${visitor.block}-${visitor.apartmentNumber})'),
                        const Divider(height: 24),
                        _Row(Icons.security_outlined, 'Registered By', visitor.securityName),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text('Timeline', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TimelineStep(
                          icon: Icons.login,
                          label: 'Entry',
                          time: visitor.entryTime,
                          done: true,
                        ),
                        _TimelineStep(
                          icon: visitor.approvalStatus == 'Rejected' ? Icons.close : Icons.check,
                          label: visitor.approvalStatus == 'Rejected' ? 'Rejected' : 'Approved',
                          time: visitor.approvedAt,
                          done: visitor.approvedAt != null,
                          color: visitor.approvalStatus == 'Rejected' ? Colors.red : null,
                        ),
                        _TimelineStep(
                          icon: Icons.logout,
                          label: 'Exit',
                          time: visitor.exitTime,
                          done: visitor.exitTime != null,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resident actions — Approve/Reject, only while Pending.
                if (role == 'Resident' && visitor.approvalStatus == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.isActionInProgress ? null : _handleReject,
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.isActionInProgress ? null : _handleApprove,
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],

                // Security action — Register Exit, only if approved and not yet exited.
                if (role == 'Security' && visitor.approvalStatus == 'Approved' && visitor.exitTime == null) ...[
                  ElevatedButton.icon(
                    onPressed: provider.isActionInProgress ? null : _handleExit,
                    icon: const Icon(Icons.logout),
                    label: const Text('Register Exit'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? time;
  final bool done;
  final bool isLast;
  final Color? color;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.time,
    required this.done,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    final dotColor = done ? activeColor : Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 14, backgroundColor: dotColor, child: Icon(icon, size: 16, color: Colors.white)),
              if (!isLast) Expanded(child: Container(width: 2, color: dotColor.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    time != null ? DateFormat('dd MMM yyyy, hh:mm a').format(time!) : 'Pending',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}