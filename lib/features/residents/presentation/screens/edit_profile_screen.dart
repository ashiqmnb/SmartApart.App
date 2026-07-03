import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../data/models/resident_models.dart';
import '../providers/resident_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  bool _isSaving = false;
  bool _isResident = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill from whatever's already loaded in the providers —
    // Profile Screen (Step 3) already fetched these before navigating
    // here, so no extra loading state is needed.
    final profile = context.read<ProfileProvider>().profile;
    final resident = context.read<ResidentProvider>().resident;

    _isResident = profile?.role == 'Resident';

    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _emergencyNameController = TextEditingController(text: resident?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: resident?.emergencyContactPhone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final profileProvider = context.read<ProfileProvider>();
    profileProvider.clearError();

    // 1. Always update name/phone via ProfileProvider.
    final profileSuccess = await profileProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (!profileSuccess) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profileProvider.errorMessage ?? 'Failed to update profile.')),
        );
      }
      return;
    }

    // 2. If Resident, also update emergency contact — backend requires
    // the full UpdateResidentRequestDto, so we carry forward the
    // existing apartment/ownership fields unchanged.
    if (_isResident && mounted) {
      final residentProvider = context.read<ResidentProvider>();
      final existing = residentProvider.resident;

      if (existing != null) {
        final residentSuccess = await residentProvider.updateResident(
          UpdateResidentRequest(
            apartmentNumber: existing.apartmentNumber,
            block: existing.block,
            floor: existing.floor,
            ownershipType: existing.ownershipType,
            moveInDate: existing.moveInDate,
            moveOutDate: existing.moveOutDate,
            emergencyContactName: _emergencyNameController.text.trim().isEmpty
                ? null
                : _emergencyNameController.text.trim(),
            emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
                ? null
                : _emergencyPhoneController.text.trim(),
          ),
        );

        if (!residentSuccess && mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(residentProvider.errorMessage ?? 'Failed to update emergency contact.')),
          );
          return;
        }
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcmsTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  validator: (v) => Validators.required(v, fieldName: 'Full name'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),

                // Emergency contact section — Resident only.
                if (_isResident) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Emergency Contact',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),

                  AcmsTextField(
                    controller: _emergencyNameController,
                    label: 'Emergency Contact Name (optional)',
                  ),
                  const SizedBox(height: 16),

                  AcmsTextField(
                    controller: _emergencyPhoneController,
                    label: 'Emergency Contact Phone (optional)',
                    keyboardType: TextInputType.phone,
                  ),
                ],

                const SizedBox(height: 24),
                AcmsButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}