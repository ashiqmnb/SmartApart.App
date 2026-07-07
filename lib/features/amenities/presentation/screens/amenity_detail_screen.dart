import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../providers/amenity_provider.dart';

/// Full amenity detail — name, description, location, hours, rules,
/// image gallery via PageView, and availability status. Admin gets
/// an Edit button (wired to CreateEditAmenityScreen in Step 7).
class AmenityDetailScreen extends StatefulWidget {
  final String amenityId;
  const AmenityDetailScreen({super.key, required this.amenityId});

  @override
  State<AmenityDetailScreen> createState() => _AmenityDetailScreenState();
}

class _AmenityDetailScreenState extends State<AmenityDetailScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AmenityProvider>().fetchDetail(widget.amenityId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    context.read<AmenityProvider>().clearSelected();
    super.dispose();
  }

  Color _availabilityColor(String availability) {
    switch (availability) {
      case 'Available':
        return Colors.green;
      case 'UnderMaintenance':
        return Colors.orange;
      case 'TemporarilyClosed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _availabilityLabel(String availability) {
    switch (availability) {
      case 'Available':
        return 'Available';
      case 'UnderMaintenance':
        return 'Under Maintenance';
      case 'TemporarilyClosed':
        return 'Temporarily Closed';
      default:
        return availability;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ProfileProvider>().profile?.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Amenity Details')),
      body: Consumer<AmenityProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final amenity = provider.selected;
          if (amenity == null) {
            return Center(child: Text(provider.errorMessage ?? 'Amenity not found.'));
          }

          final color = _availabilityColor(amenity.availability);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (amenity.images.isNotEmpty)
                _buildGallery(amenity.images)
              else
                Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.pool_outlined, size: 60, color: Colors.grey),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(amenity.name, style: Theme.of(context).textTheme.headlineSmall),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _availabilityLabel(amenity.availability),
                            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(amenity.location, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(amenity.openingTime)} - ${_formatTime(amenity.closingTime)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text('Description', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(amenity.description),

                    if (amenity.rules != null && amenity.rules!.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Rules', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(amenity.rules!),
                    ],

                    const SizedBox(height: 24),

                    if (role == 'Admin')
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Amenity'),
                        onPressed: () async {
                          await context.push('${RouteNames.editAmenity}/${amenity.id}', extra: amenity);
                          if (mounted) context.read<AmenityProvider>().fetchDetail(widget.amenityId);
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGallery(List images) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Image.network(images[index].imageUrl, fit: BoxFit.cover, width: double.infinity);
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
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

  /// Converts backend's "HH:mm:ss" TimeOnly string into a friendly
  /// "h:mm AM/PM" display format.
  String _formatTime(String raw) {
    try {
      final parts = raw.split(':');
      final hour24 = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      return '$hour12:$minute $period';
    } catch (_) {
      return raw;
    }
  }
}