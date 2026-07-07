import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../../data/models/announcement_models.dart';
import '../providers/announcement_provider.dart';

/// Shared form for creating and editing announcements.
/// Pass an existing [announcement] for Edit mode (pre-populates fields);
/// omit it for Create mode. Publish/Save Draft behavior is driven by
/// whether "Schedule for later" is toggled on — same as the backend's
/// rule: scheduledAt == null means publish immediately.
class AnnouncementFormScreen extends StatefulWidget {
  final AnnouncementDetailModel? announcement;
  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  String _noticeType = 'SocietyNotice';
  bool _isScheduled = false;
  DateTime? _scheduledAt;
  final List<XFile> _selectedAttachments = [];
  String _attachmentType = 'Image';

  bool get _isEditMode => widget.announcement != null;

  static const _noticeTypes = [
    'SocietyNotice',
    'MaintenanceNotice',
    'EmergencyAlert',
    'EventAnnouncement',
  ];
  static const _noticeLabels = {
    'SocietyNotice': 'Society Notice',
    'MaintenanceNotice': 'Maintenance Notice',
    'EmergencyAlert': 'Emergency Alert',
    'EventAnnouncement': 'Event Announcement',
  };
  static const _attachmentTypes = ['Image', 'Poster', 'Banner'];
  static const _maxAttachments = 5;

  @override
  void initState() {
    super.initState();
    final a = widget.announcement;
    _titleController = TextEditingController(text: a?.title ?? '');
    _bodyController = TextEditingController(text: a?.body ?? '');
    _noticeType = a?.noticeType ?? 'SocietyNotice';
    if (a?.scheduledAt != null && !a!.isPublished) {
      _isScheduled = true;
      _scheduledAt = a.scheduledAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    if (_selectedAttachments.length >= _maxAttachments) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can attach up to $_maxAttachments files.')),
      );
      return;
    }

    final picker = ImagePicker();
    final remaining = _maxAttachments - _selectedAttachments.length;
    final picked = await picker.pickMultiImage(imageQuality: 85);

    if (picked.isEmpty) return;

    setState(() {
      _selectedAttachments.addAll(picked.take(remaining));
    });
  }

  void _removeAttachment(int index) {
    setState(() => _selectedAttachments.removeAt(index));
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _handleSubmit() async {
    final provider = context.read<AnnouncementProvider>();
    provider.clearError();

    if (!_formKey.currentState!.validate()) return;

    if (_isScheduled && _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a schedule date and time.')),
      );
      return;
    }

    final effectiveScheduledAt = _isScheduled ? _scheduledAt : null;
    final attachmentPaths = _selectedAttachments.map((x) => x.path).toList();

    bool success;
    if (_isEditMode) {
      success = await provider.updateAnnouncement(
        widget.announcement!.id,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        noticeType: _noticeType,
        scheduledAt: effectiveScheduledAt,
        newAttachmentPaths: attachmentPaths,
        attachmentType: _attachmentType,
      );
    } else {
      final id = await provider.createAnnouncement(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        noticeType: _noticeType,
        scheduledAt: effectiveScheduledAt,
        attachmentPaths: attachmentPaths,
        attachmentType: _attachmentType,
      );
      success = id != null;
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Announcement updated successfully.'
              : (_isScheduled
              ? 'Announcement scheduled successfully.'
              : 'Announcement published successfully.')),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Announcement' : 'New Announcement')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _noticeType,
                  decoration: const InputDecoration(labelText: 'Notice Type'),
                  items: _noticeTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(_noticeLabels[t] ?? t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _noticeType = v);
                  },
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _titleController,
                  label: 'Title',
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                ),
                const SizedBox(height: 16),

                AcmsTextField(
                  controller: _bodyController,
                  label: 'Body',
                  maxLines: 6,
                  validator: (v) => Validators.required(v, fieldName: 'Body'),
                ),
                const SizedBox(height: 16),

                // Schedule toggle — reveals date/time picker when on.
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Schedule for later'),
                        subtitle: Text(
                          _isScheduled
                              ? 'Will publish automatically at the scheduled time.'
                              : 'Will publish immediately on submit.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        value: _isScheduled,
                        onChanged: (v) => setState(() => _isScheduled = v),
                      ),
                      if (_isScheduled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              _scheduledAt != null
                                  ? _formatDateTime(_scheduledAt!)
                                  : 'Pick date & time',
                            ),
                            onPressed: _pickScheduleDateTime,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attachments (optional)', style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      '${_selectedAttachments.length}/$_maxAttachments',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_selectedAttachments.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _attachmentType,
                    decoration: const InputDecoration(labelText: 'Attachment Type'),
                    items: _attachmentTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _attachmentType = v);
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                _buildAttachmentPickerRow(),
                const SizedBox(height: 24),

                Consumer<AnnouncementProvider>(
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
                          label: _isEditMode
                              ? 'Save Changes'
                              : (_isScheduled ? 'Save Draft (Scheduled)' : 'Publish Now'),
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

  Widget _buildAttachmentPickerRow() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._selectedAttachments.asMap().entries.map((entry) {
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
                      onTap: () => _removeAttachment(index),
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
          if (_selectedAttachments.length < _maxAttachments)
            GestureDetector(
              onTap: _pickAttachments,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} · $hour:$minute $period';
  }
}