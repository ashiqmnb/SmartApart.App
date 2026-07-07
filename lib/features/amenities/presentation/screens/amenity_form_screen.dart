import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../../data/models/amenity_models.dart';
import '../providers/amenity_provider.dart';

/// Shared form for creating and editing amenities.
/// Pass an existing [amenity] for Edit mode (pre-populates fields
/// including availability, updated via a separate call since it's
/// not part of CreateAmenityRequest); omit it for Create mode.
class AmenityFormScreen extends StatefulWidget {
  final AmenityDetailModel? amenity;
  const AmenityFormScreen({super.key, this.amenity});

  @override
  State<AmenityFormScreen> createState() => _AmenityFormScreenState();
}

class _AmenityFormScreenState extends State<AmenityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _rulesController;

  TimeOfDay _openingTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 22, minute: 0);
  String _availability = 'Available';
  final List<XFile> _selectedImages = [];

  bool get _isEditMode => widget.amenity != null;

  static const _availabilityOptions = ['Available', 'UnderMaintenance', 'TemporarilyClosed'];
  static const _availabilityLabels = {
    'Available': 'Available',
    'UnderMaintenance': 'Under Maintenance',
    'TemporarilyClosed': 'Temporarily Closed',
  };
  static const _maxImages = 5;

  @override
  void initState() {
    super.initState();
    final a = widget.amenity;
    _nameController = TextEditingController(text: a?.name ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _locationController = TextEditingController(text: a?.location ?? '');
    _rulesController = TextEditingController(text: a?.rules ?? '');
    _availability = a?.availability ?? 'Available';
    if (a != null) {
      _openingTime = _parseTime(a.openingTime);
      _closingTime = _parseTime(a.closingTime);
    }
  }

  TimeOfDay _parseTime(String raw) {
    try {
      final parts = raw.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  /// Converts a TimeOfDay back into "HH:mm:ss" matching backend's
  /// TimeOnly binding format.
  String _timeToBackendString(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _formatTimeDisplay(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickOpeningTime() async {
    final picked = await showTimePicker(context: context, initialTime: _openingTime);
    if (picked != null) setState(() => _openingTime = picked);
  }

  Future<void> _pickClosingTime() async {
    final picked = await showTimePicker(context: context, initialTime: _closingTime);
    if (picked != null) setState(() => _closingTime = picked);
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
    final provider = context.read<AmenityProvider>();
    provider.clearError();

    if (!_formKey.currentState!.validate()) return;

    final imagePaths = _selectedImages.map((x) => x.path).toList();

    bool success;
    String? amenityId;

    if (_isEditMode) {
      amenityId = widget.amenity!.id;
      success = await provider.updateAmenity(
        amenityId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        openingTime: _timeToBackendString(_openingTime),
        closingTime: _timeToBackendString(_closingTime),
        rules: _rulesController.text.trim().isEmpty ? null : _rulesController.text.trim(),
        newImagePaths: imagePaths,
      );

      // Availability isn't part of CreateAmenityRequest — update it
      // separately only if it actually changed, to avoid an
      // unnecessary extra API call.
      if (success && _availability != widget.amenity!.availability) {
        await provider.updateAvailability(amenityId, _availability);
      }
    } else {
      amenityId = await provider.createAmenity(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        openingTime: _timeToBackendString(_openingTime),
        closingTime: _timeToBackendString(_closingTime),
        rules: _rulesController.text.trim().isEmpty ? null : _rulesController.text.trim(),
        imagePaths: imagePaths,
      );
      success = amenityId != null;

      // New amenities default to "Available" on the backend — only
      // call updateAvailability if the admin picked something else.
      if (success && _availability != 'Available') {
        await provider.updateAvailability(amenityId!, _availability);
      }
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Amenity updated successfully.' : 'Amenity created successfully.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Amenity' : 'New Amenity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcmsTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (v) => Validators.required(v, fieldName: 'Name'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 4,
                  validator: (v) => Validators.required(v, fieldName: 'Description'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _locationController,
                  label: 'Location',
                  validator: (v) => Validators.required(v, fieldName: 'Location'),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text('Opens ${_formatTimeDisplay(_openingTime)}'),
                        onPressed: _pickOpeningTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_filled),
                        label: Text('Closes ${_formatTimeDisplay(_closingTime)}'),
                        onPressed: _pickClosingTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _rulesController,
                  label: 'Rules (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _availability,
                  decoration: const InputDecoration(labelText: 'Availability'),
                  items: _availabilityOptions
                      .map((a) => DropdownMenuItem(value: a, child: Text(_availabilityLabels[a] ?? a)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _availability = v);
                  },
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

                Consumer<AmenityProvider>(
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
                          label: _isEditMode ? 'Save Changes' : 'Create Amenity',
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