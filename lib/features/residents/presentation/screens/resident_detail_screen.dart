import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_member_provider.dart';
import '../providers/resident_detail_provider.dart';

class ResidentDetailScreen extends StatefulWidget {
  final String residentId;
  const ResidentDetailScreen({super.key, required this.residentId});

  @override
  State<ResidentDetailScreen> createState() => _ResidentDetailScreenState();
}

class _ResidentDetailScreenState extends State<ResidentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResidentDetailProvider>().fetchResident(widget.residentId);
      context.read<FamilyMemberProvider>().fetchFamilyMembers(widget.residentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resident Detail')),
      body: SafeArea(
        child: Consumer<ResidentDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.resident == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final resident = provider.resident;
            if (resident == null) {
              return Center(child: Text(provider.errorMessage ?? 'Resident not found.'));
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: resident.profilePhotoUrl != null
                        ? NetworkImage(resident.profilePhotoUrl!)
                        : null,
                    child: resident.profilePhotoUrl == null
                        ? Text(resident.fullName.isNotEmpty ? resident.fullName[0].toUpperCase() : '?')
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(resident.fullName, style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row('Email', resident.email),
                        const Divider(height: 24),
                        _Row('Phone', resident.phoneNumber),
                        const Divider(height: 24),
                        _Row('Apartment', '${resident.block} - ${resident.apartmentNumber}'),
                        const Divider(height: 24),
                        _Row('Floor', resident.floor.toString()),
                        const Divider(height: 24),
                        _Row('Ownership', resident.ownershipType),
                        if (resident.emergencyContactName != null) ...[
                          const Divider(height: 24),
                          _Row('Emergency Contact', resident.emergencyContactName!),
                        ],
                        if (resident.emergencyContactPhone != null) ...[
                          const Divider(height: 24),
                          _Row('Emergency Phone', resident.emergencyContactPhone!),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text('Family Members', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),

                Consumer<FamilyMemberProvider>(
                  builder: (context, famProvider, _) {
                    if (famProvider.isLoading && famProvider.members.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (famProvider.members.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('No family members.', style: Theme.of(context).textTheme.bodySmall),
                      );
                    }
                    return Column(
                      children: famProvider.members
                          .map((m) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?'),
                          ),
                          title: Text(m.fullName),
                          subtitle: Text(m.relationship),
                        ),
                      ))
                          .toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}