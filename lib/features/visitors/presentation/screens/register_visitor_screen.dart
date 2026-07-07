import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../../../residents/data/models/resident_models.dart';
import '../../data/models/visitor_models.dart';
import '../providers/visitor_provider.dart';
import '../widgets/resident_search_delegate.dart';

class RegisterVisitorScreen extends StatefulWidget {
  const RegisterVisitorScreen({super.key});

  @override
  State<RegisterVisitorScreen> createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _visitorNameController = TextEditingController();
  final _visitorPhoneController = TextEditingController();
  final _purposeController = TextEditingController();
  final _vehicleController = TextEditingController();

  ResidentPublicModel? _selectedResident;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _visitorNameController.dispose();
    _visitorPhoneController.dispose();
    _purposeController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _handlePickResident() async {
    final result = await showSearch<ResidentPublicModel?>(
      context: context,
      delegate: ResidentSearchDelegate(),
    );
    if (result != null) {
      setState(() => _selectedResident = result);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedResident == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the resident being visited.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<VisitorProvider>();
    provider.clearError();

    final success = await provider.registerVisitor(
      RegisterVisitorRequest(
        residentId: _selectedResident!.id,
        visitorName: _visitorNameController.text.trim(),
        visitorPhone: _visitorPhoneController.text.trim(),
        purpose: _purposeController.text.trim(),
        vehicleNumber: _vehicleController.text.trim().isEmpty
            ? null
            : _vehicleController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor registered. Waiting for resident approval.')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.detailErrorMessage ?? 'Failed to register visitor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Visitor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Resident picker — styled like a text field but opens
                // the search delegate on tap instead of a keyboard,
                // same pattern as the Date of Birth picker in
                // AddEditFamilyMemberScreen.
                InkWell(
                  onTap: _handlePickResident,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Visiting Resident',
                      suffixIcon: Icon(Icons.search),
                    ),
                    child: Text(
                      _selectedResident != null
                          ? '${_selectedResident!.fullName} (${_selectedResident!.block}-${_selectedResident!.apartmentNumber})'
                          : 'Tap to search resident',
                      style: _selectedResident == null
                          ? TextStyle(color: Theme.of(context).hintColor)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _visitorNameController,
                  label: 'Visitor Name',
                  validator: (v) => Validators.required(v, fieldName: 'Visitor name'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _visitorPhoneController,
                  label: 'Visitor Phone',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _purposeController,
                  label: 'Purpose of Visit',
                  validator: (v) => Validators.required(v, fieldName: 'Purpose'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _vehicleController,
                  label: 'Vehicle Number (optional)',
                ),

                const SizedBox(height: 24),
                AcmsButton(
                  label: 'Register Visitor',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}