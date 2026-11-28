import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/colors.dart';
import '../models/contact.dart';
import '../widgets/caregiver_widgets.dart';
import 'caregiver_add_contact_screen.dart';

/// People the patient knows: photo, name, relation and phone.
class CaregiverContactsScreen extends StatefulWidget {
  const CaregiverContactsScreen({super.key});

  @override
  State<CaregiverContactsScreen> createState() =>
      _CaregiverContactsScreenState();
}

class _CaregiverContactsScreenState extends State<CaregiverContactsScreen> {
  final _service = ContactService();
  String _search = '';
  String? _patientId;
  List<Contact> _contacts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _patientId ??= await _service.getMyPatientId();
      if (_patientId == null) {
        _error = 'No patient is linked to this account.';
      } else {
        final rows = await _service.fetchContacts(_patientId!);
        _contacts = await Future.wait(rows.map((r) async => Contact.fromMap(
          r,
          photoUrl:
          await _service.getPhotoUrl(r['photo_path'] as String?),
        )));
      }
    } catch (e) {
      _error = 'Could not load contacts: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openEditor([Contact? contact]) async {
    if (_patientId == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CaregiverAddContactScreen(
          contact: contact,
          patientId: _patientId!,
        ),
      ),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _contacts;
    final q = _search.trim().toLowerCase();
    final shown = contacts
        .where((c) =>
    q.isEmpty ||
        c.name.toLowerCase().contains(q) ||
        c.relation.toLowerCase().contains(q))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            PageHeader(
              subtitle: 'Familiar faces for John',
              title: 'Contacts',
              trailing: Material(
                color: AppColors.deepBlue,
                borderRadius: BorderRadius.circular(18),
                child: IconButton(
                  tooltip: 'Add contact',
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (contacts.isNotEmpty) ...[
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or relation',
                  hintStyle: const TextStyle(color: AppColors.muted),
                  prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.muted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _load,
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.deepBlue),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
                  : contacts.isEmpty
                  ? _EmptyState(onAdd: () => _openEditor())
                  : RefreshIndicator(
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: shown.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 268,
                  ),
                  itemBuilder: (context, index) {
                    final c = shown[index];
                    return _ContactCard(
                      contact: c,
                      colorIndex: contacts.indexOf(c),
                      onCall: () => callNumber(context, c.phone),
                      onEdit: () => _openEditor(c),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final int colorIndex;
  final VoidCallback onCall;
  final VoidCallback onEdit;

  const _ContactCard({
    required this.contact,
    required this.colorIndex,
    required this.onCall,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Photo + red emergency badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              ContactAvatar(contact: contact, colorIndex: colorIndex),
              if (contact.isEmergency)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.emergency_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            contact.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              contact.relation,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contact.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onCall,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: AppColors.greenText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: const Text('Call',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  tooltip: 'Edit ${contact.name}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.deepBlue, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconBadge(
            icon: Icons.people_outline,
            size: 80,
            background: AppColors.lightGreen,
            color: AppColors.green,
          ),
          const SizedBox(height: 16),
          const Text('No contacts yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Add the people John knows, with a photo, so he can recognise them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deepBlue,
              minimumSize: const Size(0, 52),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add first contact',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Supabase: save / load / edit / delete contacts and photos
// ─────────────────────────────────────────────────────────────
class ContactService {
  final _db = Supabase.instance.client;

  Future<String?> getMyPatientId() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _db
        .from('caregiver_patients')
        .select('patient_id')
        .eq('caregiver_id', uid)
        .limit(1)
        .maybeSingle();
    return row?['patient_id'] as String?;
  }

  Future<List<Map<String, dynamic>>> fetchContacts(String patientId) async {
    return await _db
        .from('contacts')
        .select()
        .eq('patient_id', patientId)
        .order('created_at');
  }

  Future<String> _uploadPhoto(String patientId, Uint8List bytes) async {
    final path = '$patientId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _db.storage.from('contact-photos').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    return path;
  }

  Future<void> addContact({
    required String patientId,
    required String fullName,
    String? phone,
    required String relationship,
    String? reminderNote,
    Uint8List? photoBytes,
    bool isEmergency = false,
  }) async {
    final photoPath =
    photoBytes != null ? await _uploadPhoto(patientId, photoBytes) : null;
    await _db.from('contacts').insert({
      'patient_id': patientId,
      'full_name': fullName,
      'phone': phone,
      'relationship': relationship.toLowerCase(),
      'reminder_note': reminderNote,
      'photo_path': photoPath,
      'is_emergency': isEmergency,
    });
  }

  Future<void> updateContact({
    required String id,
    required String patientId,
    required String fullName,
    String? phone,
    required String relationship,
    String? reminderNote,
    Uint8List? photoBytes,
    bool? isEmergency, // NEW: only saved if given
  }) async {
    final data = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'relationship': relationship.toLowerCase(),
      'reminder_note': reminderNote,
    };
    if (isEmergency != null) {
      data['is_emergency'] = isEmergency;
    }
    if (photoBytes != null) {
      data['photo_path'] = await _uploadPhoto(patientId, photoBytes);
    }
    await _db.from('contacts').update(data).eq('id', id);
  }

  Future<String?> getPhotoUrl(String? path) async {
    if (path == null) return null;
    return await _db.storage
        .from('contact-photos')
        .createSignedUrl(path, 60 * 60);
  }

  Future<void> deleteContact(String id) async {
    await _db.from('contacts').delete().eq('id', id);
  }
}