import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/announcement_models.dart';
import '../providers/announcement_provider.dart';

/// Feed of published announcements with notice type filter chips.
/// Emergency Alerts get a distinct red banner treatment in the card
/// itself, so they stand out even in a mixed feed.
class AnnouncementFeedScreen extends StatefulWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  State<AnnouncementFeedScreen> createState() => _AnnouncementFeedScreenState();
}

class _AnnouncementFeedScreenState extends State<AnnouncementFeedScreen> {
  final _scrollController = ScrollController();
  String? _selectedType;

  static const _noticeTypes = [
    'SocietyNotice',
    'MaintenanceNotice',
    'EmergencyAlert',
    'EventAnnouncement',
  ];

  static const _noticeLabels = {
    'SocietyNotice': 'Society',
    'MaintenanceNotice': 'Maintenance',
    'EmergencyAlert': 'Emergency',
    'EventAnnouncement': 'Event',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchPublished();
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
      context.read<AnnouncementProvider>().fetchMore();
    }
  }

  void _selectType(String? type) {
    setState(() => _selectedType = type);
    context.read<AnnouncementProvider>().fetchPublished(noticeType: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.published.isEmpty) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.published.isEmpty) {
                  return const Center(child: Text('No announcements yet.'));
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchPublished(noticeType: _selectedType),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.published.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.published.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildCard(provider.published[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _selectedType == null,
              onSelected: (_) => _selectType(null),
            ),
          ),
          ..._noticeTypes.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_noticeLabels[type] ?? type),
              selected: _selectedType == type,
              onSelected: (_) => _selectType(type),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCard(AnnouncementListModel announcement) {
    final isEmergency = announcement.noticeType == 'EmergencyAlert';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isEmergency ? Colors.red.shade50 : null,
      shape: isEmergency
          ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.red.shade300, width: 1.2),
      )
          : null,
      child: ListTile(
        onTap: () => context.push('${RouteNames.announcementDetail}/${announcement.id}'),
        leading: Icon(
          isEmergency ? Icons.warning_amber_rounded : Icons.campaign_outlined,
          color: isEmergency ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          announcement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isEmergency ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        subtitle: Text(_noticeLabels[announcement.noticeType] ?? announcement.noticeType),
        trailing: Text(
          announcement.publishedAt != null
              ? _formatDate(announcement.publishedAt!)
              : '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}