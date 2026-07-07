import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/visitor_models.dart';
import '../providers/visitor_provider.dart';

class VisitorLogScreen extends StatefulWidget {
  const VisitorLogScreen({super.key});

  @override
  State<VisitorLogScreen> createState() => _VisitorLogScreenState();
}

class _VisitorLogScreenState extends State<VisitorLogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  // Tab index -> backend status filter value (null = All).
  static const _tabs = <String?>[null, 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<VisitorProvider>().setStatusFilter(_tabs[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorProvider>().fetchVisitors();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<VisitorProvider>().fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Log'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<VisitorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.visitors.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null && provider.visitors.isEmpty) {
              return Center(child: Text(provider.errorMessage!));
            }

            if (provider.visitors.isEmpty) {
              return Center(
                child: Text(
                  'No visitors found.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.fetchVisitors,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.visitors.length + (provider.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= provider.visitors.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final visitor = provider.visitors[index];
                  return _VisitorCard(
                    visitor: visitor,
                    onTap: () => context.push(
                      RouteNames.visitorDetail,
                      extra: visitor.id,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorListModel visitor;
  final VoidCallback onTap;

  const _VisitorCard({required this.visitor, required this.onTap});

  Color _statusColor(BuildContext context) {
    switch (visitor.approvalStatus) {
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
    final statusColor = _statusColor(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(Icons.person_outline, color: statusColor),
        ),
        title: Text(visitor.visitorName),
        subtitle: Text(
          '${visitor.purpose} • ${visitor.block}-${visitor.apartmentNumber}\n'
              '${DateFormat('dd MMM, hh:mm a').format(visitor.entryTime)}',
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(
            visitor.approvalStatus,
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          backgroundColor: statusColor.withValues(alpha: 0.12),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}