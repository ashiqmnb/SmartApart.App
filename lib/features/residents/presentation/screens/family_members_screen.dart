import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/family_member_models.dart';
import '../providers/family_member_provider.dart';
import '../providers/resident_provider.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMembers());
  }

  Future<void> _loadMembers() async {
    final residentProvider = context.read<ResidentProvider>();

    // Ensure the resident record is loaded — don't assume Profile
    // Screen already did this, since this screen could be reached
    // via hot reload or a deep link in the future.
    if (residentProvider.resident == null) {
      await residentProvider.fetchMyProfile();
    }

    if (!mounted) return;
    final residentId = residentProvider.resident?.id;
    if (residentId == null) return;

    await context.read<FamilyMemberProvider>().fetchFamilyMembers(residentId);
  }

  Future<void> _handleDelete(FamilyMemberModel member) async {
    final residentId = context.read<ResidentProvider>().resident?.id;
    if (residentId == null) return;

    final provider = context.read<FamilyMemberProvider>();
    final success = await provider.deleteFamilyMember(residentId, member.id);

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete family member.')),
      );
      // Re-sync the list since the optimistic removal in Dismissible's
      // onDismissed already happened visually — refetch to correct it.
      await _loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addFamilyMember),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Consumer<FamilyMemberProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.members.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.members.isEmpty) {
              return RefreshIndicator(
                onRefresh: _loadMembers,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 56,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No family members added yet.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + to add one.',
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

            return RefreshIndicator(
              onRefresh: _loadMembers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.members.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = provider.members[index];
                  return Dismissible(
                    key: ValueKey(member.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Family Member'),
                          content: Text('Remove ${member.fullName} from your household?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                    },
                    onDismissed: (_) => _handleDelete(member),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => context.push(
                          RouteNames.editFamilyMember,
                          extra: member,
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                          ),
                        ),
                        title: Text(member.fullName),
                        subtitle: Text(
                          [
                            member.relationship,
                            if (member.dateOfBirth != null)
                              DateFormat('dd MMM yyyy').format(member.dateOfBirth!),
                          ].join(' • '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
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