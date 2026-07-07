import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';

/// Full announcement detail — title, body, notice type badge,
/// published date, and a PageView carousel for image/poster/banner
/// attachments if any exist.
class AnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _noticeLabels = {
    'SocietyNotice': 'Society Notice',
    'MaintenanceNotice': 'Maintenance Notice',
    'EmergencyAlert': 'Emergency Alert',
    'EventAnnouncement': 'Event',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchDetail(widget.announcementId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    context.read<AnnouncementProvider>().clearSelected();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcement = provider.selected;
          if (announcement == null) {
            return Center(child: Text(provider.errorMessage ?? 'Announcement not found.'));
          }

          final isEmergency = announcement.noticeType == 'EmergencyAlert';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (isEmergency)
                Container(
                  width: double.infinity,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'EMERGENCY ALERT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              if (announcement.attachments.isNotEmpty) _buildCarousel(announcement.attachments),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(_noticeLabels[announcement.noticeType] ?? announcement.noticeType),
                      backgroundColor: isEmergency
                          ? Colors.red.shade50
                          : Theme.of(context).colorScheme.primaryContainer,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(height: 10),
                    Text(announcement.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      announcement.publishedAt != null
                          ? 'Published on ${_formatDate(announcement.publishedAt!)} by ${announcement.createdByName}'
                          : 'By ${announcement.createdByName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    Text(announcement.body),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarousel(List attachments) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: attachments.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              return Image.network(
                attachment.fileUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        if (attachments.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(attachments.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}