import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/announcement_models.dart';
import '../providers/announcement_provider.dart';

/// Admin-only screen — tab view of Published vs Drafts (scheduled/
/// unpublished). Each card shows schedule/published status with
/// Edit, Delete, and (Drafts only) Publish Now actions.
class AdminAnnouncementListScreen extends StatefulWidget {
  const AdminAnnouncementListScreen({super.key});

  @override
  State<AdminAnnouncementListScreen> createState() => _AdminAnnouncementListScreenState();
}

class _AdminAnnouncementListScreenState extends State<AdminAnnouncementListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnnouncementProvider>();
      provider.fetchPublished();
      provider.fetchDrafts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Announcements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Published'),
            Tab(text: 'Drafts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublishedTab(),
          _buildDraftsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPublishedTab() {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.published.isEmpty) {
          return const Center(child: Text('No published announcements.'));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchPublished(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.published.length,
            itemBuilder: (context, index) =>
                _buildCard(provider.published[index], isDraft: false),
          ),
        );
      },
    );
  }

  Widget _buildDraftsTab() {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, _) {
        if (provider.isDraftsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.drafts.isEmpty) {
          return const Center(child: Text('No scheduled drafts.'));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchDrafts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.drafts.length,
            itemBuilder: (context, index) =>
                _buildCard(provider.drafts[index], isDraft: true),
          ),
        );
      },
    );
  }

  Widget _buildCard(AnnouncementListModel announcement, {required bool isDraft}) {
    final isEmergency = announcement.noticeType == 'EmergencyAlert';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isEmergency)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                  ),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isDraft
                  ? (announcement.scheduledAt != null
                  ? 'Scheduled for ${_formatDateTime(announcement.scheduledAt!)}'
                  : 'Draft — not scheduled')
                  : (announcement.publishedAt != null
                  ? 'Published ${_formatDateTime(announcement.publishedAt!)}'
                  : 'Published'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDraft)
                  TextButton.icon(
                    icon: const Icon(Icons.publish, size: 18),
                    label: const Text('Publish Now'),
                    onPressed: () => _confirmPublish(announcement),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  onPressed: () => _navigateToEdit(announcement),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => _confirmDelete(announcement),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(AnnouncementListModel announcement) async {
    final provider = context.read<AnnouncementProvider>();
    // Fetch full detail first — the list model doesn't carry body/attachments,
    // and the edit form's 'extra' expects an AnnouncementDetailModel.
    await provider.fetchDetail(announcement.id);
    final detail = provider.selected;
    if (detail == null || !mounted) return;

    await context.push('${RouteNames.editAnnouncement}/${announcement.id}', extra: detail);
    if (mounted) {
      provider.fetchPublished();
      provider.fetchDrafts();
    }
  }

  Future<void> _handleCreate() async {
    await context.push(RouteNames.createAnnouncement);
    // Refresh both lists after returning from Create — the new
    // announcement lands in Published or Drafts depending on
    // whether it was scheduled.
    if (!mounted) return;
    final provider = context.read<AnnouncementProvider>();
    provider.fetchPublished();
    provider.fetchDrafts();
  }

  Future<void> _confirmPublish(AnnouncementListModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Now?'),
        content: Text('Publish "${announcement.title}" immediately instead of waiting for its schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publish')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AnnouncementProvider>();
      final success = await provider.publishDraft(announcement.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement published.')),
        );
        provider.fetchPublished();
      }
    }
  }

  Future<void> _confirmDelete(AnnouncementListModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement?'),
        content: Text('This will permanently delete "${announcement.title}" and its attachments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AnnouncementProvider>();
      final success = await provider.deleteAnnouncement(announcement.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted.')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} · $hour:$minute $period';
  }
}