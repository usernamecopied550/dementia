import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/contact.dart';
import 'caregiver_contacts_screen.dart' show ContactService;

/// Form to add or edit a person the patient knows.
class CaregiverAddContactScreen extends StatefulWidget {
  final Contact? contact; // null = add, not null = edit
  final String patientId;

  const CaregiverAddContactScreen({
    super.key,
    this.contact,
    required this.patientId,
  });

  @override
  State<CaregiverAddContactScreen> createState() =>
      _CaregiverAddContactScreenState();
}

class _CaregiverAddContactScreenState extends State<CaregiverAddContactScreen> {
  static const _relations = [
    'Daughter', 'Son', 'Spouse', 'Grandchild',
    'Friend', 'Doctor', 'Neighbour', 'Other',
  ];

  static const _red = Color(0xFFD32F2F);
  static const _lightRed = Color(0xFFFDECEC);

  final _service = ContactService();
  late final _name = TextEditingController(text: widget.contact?.name ?? '');
  late final _phone = TextEditingController(text: widget.contact?.phone ?? '');
  late final _note = TextEditingController(text: widget.contact?.note ?? '');
  late String _relation = widget.contact?.relation ?? 'Daughter';
  late bool _isEmergency = widget.contact?.isEmergency ?? false;
  Uint8List? _photoBytes;
  bool _saving = false;

  bool get _isEdit => widget.contact?.id != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _snack('Please enter a name.');
      return;
    }
    final phone = _phone.text.trim();
    final note = _note.text.trim();

    if (_isEmergency && phone.isEmpty) {
      _snack('An emergency contact needs a phone number.');
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _service.updateContact(
          id: widget.contact!.id!,
          patientId: widget.patientId,
          fullName: name,
          phone: phone.isEmpty ? null : phone,
          relationship: _relation,
          reminderNote: note.isEmpty ? null : note,
          photoBytes: _photoBytes,
          isEmergency: _isEmergency,
        );
      } else {
        await _service.addContact(
          patientId: widget.patientId,
          fullName: name,
          phone: phone.isEmpty ? null : phone,
          relationship: _relation,
          reminderNote: note.isEmpty ? null : note,
          photoBytes: _photoBytes,
          isEmergency: _isEmergency,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Could not save: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.contact!.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await _service.deleteContact(widget.contact!.id!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Could not delete: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (_photoBytes != null) {
      image = MemoryImage(_photoBytes!);
    } else if (widget.contact?.photoUrl != null) {
      image = NetworkImage(widget.contact!.photoUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: AppColors.deepBlue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit person' : 'Add a person',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink),
                    ),
                  ),
                  if (_isEdit)
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _saving ? null : _delete,
                    ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 72,
                            backgroundColor: AppColors.softBlue,
                            backgroundImage: image,
                            child: image == null
                                ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_camera_outlined,
                                    color: AppColors.deepBlue, size: 32),
                                SizedBox(height: 6),
                                Text('Add photo',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.deepBlue)),
                              ],
                            )
                                : null,
                          ),
                          const Positioned(
                            right: 4,
                            bottom: 4,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.deepBlue,
                              child: Icon(Icons.add,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A clear, recent face photo helps John recognise them',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  _card([
                    _label('Full name'),
                    _field(_name, 'e.g. Sarah Doe'),
                    const SizedBox(height: 14),
                    _label('Phone number'),
                    _field(_phone, '+212 6 00 00 00 00',
                        keyboard: TextInputType.phone),
                  ]),
                  const SizedBox(height: 12),
                  _card([
                    _label('Who is this person to John?'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _relations.map((r) {
                        final sel = r == _relation;
                        return ChoiceChip(
                          label: Text(r),
                          selected: sel,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _relation = r),
                          selectedColor: AppColors.blue,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: sel ? AppColors.ink : AppColors.deepBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: sel
                                  ? Colors.transparent
                                  : const Color(0xFFDDE5EE),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text.rich(
                      TextSpan(
                        text: 'How to remind John who they are ',
                        children: [
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    _field(_note, 'e.g. Your daughter. She visits every Sunday.',
                        maxLines: 3),
                  ]),
                  const SizedBox(height: 12),

                  // NEW: Emergency contact switch
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                    decoration: BoxDecoration(
                      color: _isEmergency ? _lightRed : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isEmergency ? _red : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isEmergency ? _red : _lightRed,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.emergency_rounded,
                            color: _isEmergency ? Colors.white : _red,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency contact',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'John can call them with the red help button',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isEmergency,
                          activeColor: Colors.white,
                          activeTrackColor: _red,
                          onChanged: (v) => setState(() => _isEmergency = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.deepBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.check_rounded),
                        label: const Text('Save contact',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
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

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink)),
  );

  Widget _field(TextEditingController c, String hint,
      {TextInputType? keyboard, int maxLines = 1}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted),
          filled: true,
          fillColor: const Color(0xFFF6F8FA),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDE5EE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDE5EE)),
          ),
        ),
      );
}