import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../providers/complaint_provider.dart';

/// Form to submit a new complaint — category dropdown, Normal/Anonymous
/// toggle, title/description, and an optional multi-image picker
/// (max 5), same pattern as CreateMaintenanceScreen.
class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Noise';
  bool _isAnonymous = false;
  final List<XFile> _selectedImages = [];

  static const _categories = [
    'Noise',
    'Parking',
    'Garbage',
    'Security',
    'NeighbourDisputes',
    'Other',
  ];
  static const _maxImages = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can attach up to $_maxImages photos.')),
      );
      return;
    }

    final picker = ImagePicker();
    final remaining = _maxImages - _selectedImages.length;
    final picked = await picker.pickMultiImage(imageQuality: 80);

    if (picked.isEmpty) return;

    setState(() {
      _selectedImages.addAll(picked.take(remaining));
    });
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _handleSubmit() async {
    context.read<ComplaintProvider>().clearError();

    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ComplaintProvider>().createComplaint(
      category: _category,
      complaintType: _isAnonymous ? 'Anonymous' : 'Normal',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePaths: _selectedImages.map((x) => x.path).toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully.')),
      );
      context.pop();
      context.read<ComplaintProvider>().fetchComplaints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Complaint')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 16),

                // Normal/Anonymous toggle — a SwitchListTile reads
                // naturally here, similar to a labeled checkbox/toggle
                // in a React form.
                Card(
                  margin: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: const Text('Submit anonymously'),
                    subtitle: Text(
                      _isAnonymous
                          ? 'Your identity will be hidden from Admin.'
                          : 'Your name will be visible to Admin.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v),
                  ),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _titleController,
                  label: 'Title',
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 4,
                  validator: (v) => Validators.required(v, fieldName: 'Description'),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Photos (optional)', style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      '${_selectedImages.length}/$_maxImages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildImagePickerRow(),
                const SizedBox(height: 24),

                Consumer<ComplaintProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      children: [
                        if (provider.errorMessage != null) ...[
                          Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        AcmsButton(
                          label: 'Submit Complaint',
                          isLoading: provider.isSubmitting,
                          onPressed: _handleSubmit,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerRow() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_selectedImages.length < _maxImages)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}