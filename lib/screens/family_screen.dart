import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/colors.dart';
import '../models/contact.dart';
import '../widgets/caregiver_widgets.dart';
import 'caregiver_contacts_screen.dart' show ContactService;

/// The people the patient knows, added by the caregiver.
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _service = ContactService();
  late Future<List<Contact>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Contact>> _load() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _service.fetchContacts(uid);
    final people = await Future.wait(rows.map((r) async => Contact.fromMap(
      r,
      photoUrl: await _service.getPhotoUrl(r['photo_path'] as String?),
    )));
    // Emergency contacts first
    people.sort((a, b) {
      if (a.isEmergency == b.isEmergency) return 0;
      return a.isEmergency ? -1 : 1;
    });
    return people;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'My family',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Contact>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Could not load your family.',
                          style: TextStyle(fontSize: 20, color: AppColors.muted),
                        ),
                      );
                    }

                    final people = snapshot.data ?? [];

                    if (people.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconBadge(
                              icon: Icons.people_alt_rounded,
                              size: 88,
                              background: AppColors.lightBlue,
                              color: AppColors.deepBlue,
                            ),
                            SizedBox(height: 18),
                            Text(
                              'No one added yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: people.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _PersonCard(contact: people[index], colorIndex: index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Contact contact;
  final int colorIndex;

  const _PersonCard({required this.contact, required this.colorIndex});

  static const _red = Color(0xFFD32F2F);
  static const _lightRed = Color(0xFFFDECEC);

  @override
  Widget build(BuildContext context) {
    final firstName = contact.name.trim().split(' ').first;
    final note = contact.note;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: contact.isEmergency
            ? Border.all(color: _red.withOpacity(0.5), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo + red emergency badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ContactAvatar(
                      contact: contact, size: 88, colorIndex: colorIndex),
                  if (contact.isEmergency)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.emergency_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _tag(contact.relation, AppColors.lightBlue,
                            AppColors.deepBlue),
                        if (contact.isEmergency)
                          _tag('Emergency', _lightRed, _red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              note,
              style: const TextStyle(
                fontSize: 19,
                height: 1.3,
                color: AppColors.muted,
              ),
            ),
          ],
          if (contact.phone.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton.icon(
                onPressed: () => callNumber(context, contact.phone),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.call_rounded, size: 28),
                label: Text(
                  'Call $firstName',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}