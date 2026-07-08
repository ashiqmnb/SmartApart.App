import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../providers/resident_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget fetches on mount — same pattern as a useEffect
    // with an empty dependency array in React.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.fetchProfile();

    // Only fetch the apartment record if the user is a Resident —
    // Admin/Security don't have a Resident row.
    if (!mounted) return;
    if (profileProvider.profile?.role == 'Resident') {
      await context.read<ResidentProvider>().fetchMyProfile();
    }
  }

  Future<void> _handlePickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // basic compression before upload
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    final success = await context.read<ProfileProvider>().updatePhoto(picked.path);
    if (mounted) {
      setState(() => _uploadingPhoto = false);
      if (!success) {
        final error = context.read<ProfileProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to update photo.')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            if (profileProvider.isLoading && profileProvider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = profileProvider.profile;
            if (profile == null) {
              return Center(
                child: Text(profileProvider.errorMessage ?? 'Could not load profile.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          backgroundImage: profile.profilePhotoUrl != null
                              ? CachedNetworkImageProvider(profile.profilePhotoUrl!)
                              : null,
                          child: profile.profilePhotoUrl == null
                              ? Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 32),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadingPhoto ? null : _handlePickPhoto,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: _uploadingPhoto
                                  ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      profile.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Chip(
                      label: Text(profile.role),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                          const Divider(height: 24),
                          _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: profile.phoneNumber),
                        ],
                      ),
                    ),
                  ),

                  // Apartment info card — Resident only.
                  if (profile.role == 'Resident') ...[
                    const SizedBox(height: 16),
                    Consumer<ResidentProvider>(
                      builder: (context, residentProvider, _) {
                        final resident = residentProvider.resident;
                        if (residentProvider.isLoading && resident == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (resident == null) return const SizedBox.shrink();

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apartment Details',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  icon: Icons.apartment_outlined,
                                  label: 'Apartment',
                                  value: '${resident.block} - ${resident.apartmentNumber}',
                                ),
                                const Divider(height: 24),
                                _InfoRow(
                                  icon: Icons.layers_outlined,
                                  label: 'Floor',
                                  value: resident.floor.toString(),
                                ),
                                const Divider(height: 24),
                                _InfoRow(
                                  icon: Icons.key_outlined,
                                  label: 'Ownership',
                                  value: resident.ownershipType,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(RouteNames.familyMembers),
                      icon: const Icon(Icons.people_outline),
                      label: const Text('Family Members'),
                    ),
                  ],

                  const SizedBox(height: 24),
                  AcmsButton(
                    label: 'Edit Profile',
                    onPressed: () => context.push(RouteNames.editProfile),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

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