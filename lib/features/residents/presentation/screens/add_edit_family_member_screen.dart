import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../../data/models/family_member_models.dart';
import '../providers/family_member_provider.dart';
import '../providers/resident_provider.dart';

class AddEditFamilyMemberScreen extends StatefulWidget {
  /// Null when adding a new member; populated when editing an existing one.
  final FamilyMemberModel? existingMember;

  const AddEditFamilyMemberScreen({super.key, this.existingMember});

  @override
  State<AddEditFamilyMemberScreen> createState() => _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _phoneController;

  DateTime? _dateOfBirth;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingMember != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMember;

    _fullNameController = TextEditingController(text: existing?.fullName ?? '');
    _relationshipController = TextEditingController(text: existing?.relationship ?? '');
    _phoneController = TextEditingController(text: existing?.phoneNumber ?? '');
    _dateOfBirth = existing?.dateOfBirth;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final residentProvider = context.read<ResidentProvider>();

    // Fallback: if resident wasn't loaded before reaching this screen,
    // fetch it now rather than failing outright.
    if (residentProvider.resident == null) {
      await residentProvider.fetchMyProfile();
    }

    final residentId = residentProvider.resident?.id;
    if (!mounted) return;
    if (residentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(residentProvider.errorMessage ?? 'Could not load resident profile. Please try again.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<FamilyMemberProvider>();
    provider.clearError();

    final dto = FamilyMemberRequest(
      fullName: _fullNameController.text.trim(),
      relationship: _relationshipController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );

    final success = _isEditMode
        ? await provider.updateFamilyMember(residentId, widget.existingMember!.id, dto)
        : await provider.addFamilyMember(residentId, dto);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Family member updated.' : 'Family member added.')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Failed to save family member.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Family Member' : 'Add Family Member')),
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
                  controller: _relationshipController,
                  label: 'Relationship',
                  validator: (v) => Validators.required(v, fieldName: 'Relationship'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _phoneController,
                  label: 'Phone Number (optional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Date of birth picker — styled to look like a text field
                // but opens showDatePicker on tap instead of a keyboard.
                InkWell(
                  onTap: _pickDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (optional)',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? DateFormat('dd MMM yyyy').format(_dateOfBirth!)
                          : 'Select date',
                      style: _dateOfBirth == null
                          ? TextStyle(color: Theme.of(context).hintColor)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                AcmsButton(
                  label: _isEditMode ? 'Save Changes' : 'Add Family Member',
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