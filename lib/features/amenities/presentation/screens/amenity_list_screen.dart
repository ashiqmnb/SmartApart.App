import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/amenity_models.dart';
import '../providers/amenity_provider.dart';

/// Grid of amenity cards with color-coded availability badges.
/// No pagination/infinite scroll — amenities are a small, fixed set
/// per the repository design (Step 1).
class AmenityListScreen extends StatefulWidget {
  const AmenityListScreen({super.key});

  @override
  State<AmenityListScreen> createState() => _AmenityListScreenState();
}

class _AmenityListScreenState extends State<AmenityListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AmenityProvider>().fetchAmenities();
    });
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
        return 'Closed';
      default:
        return availability;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amenities')),
      body: Consumer<AmenityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.amenities.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.amenities.isEmpty) {
            return const Center(child: Text('No amenities found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAmenities(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.amenities.length,
              itemBuilder: (context, index) => _buildCard(provider.amenities[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(RouteNames.createAmenity);
          if (context.mounted) context.read<AmenityProvider>().fetchAmenities();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(AmenityListModel amenity) {
    final color = _availabilityColor(amenity.availability);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${RouteNames.amenityDetail}/${amenity.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: amenity.thumbnailUrl != null
                  ? Image.network(amenity.thumbnailUrl!, fit: BoxFit.cover)
                  : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.pool_outlined, size: 40, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amenity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amenity.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _availabilityLabel(amenity.availability),
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}