import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/caregiver_widgets.dart';

/// Caregiver's view of the patient profile.
class PatientInfoScreen extends StatefulWidget {
  final VoidCallback? onOpenContacts;

  const PatientInfoScreen({super.key, this.onOpenContacts});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _load();
  }

  Future<Map<String, dynamic>?> _load() async {
    final db = Supabase.instance.client;
    final uid = db.auth.currentUser?.id;
    if (uid == null) return null;
    final link = await db.from('caregiver_patients')
        .select('patient_id').eq('caregiver_id', uid).maybeSingle();
    if (link == null) return null;
    final patientId = link['patient_id'];
    final profile = await db.from('profiles').select('full_name')
        .eq('id', patientId).single();
    final contacts = await db.from('contacts')
        .select('full_name, phone, is_emergency')
        .eq('patient_id', patientId).order('created_at');
    return {'name': profile['full_name'], 'contacts': contacts};
  }

  void _retry() {
    setState(() => _profileFuture = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load patient profile.'),
              TextButton(onPressed: _retry, child: const Text('Retry')),
            ],
          ));
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No patient linked.'));
        }
        final rawName = (data['name'] ?? '').toString().trim();
        final name = rawName.isEmpty ? 'Patient' : rawName;
        final initials = name.split(RegExp(r'\s+')).take(2)
            .map((part) => part.characters.first.toUpperCase()).join();
        final contacts = List<Map<String, dynamic>>.from(data['contacts'] as List);
        final emergency = contacts.where((c) => c['is_emergency'] == true &&
            (c['phone'] ?? '').toString().trim().isNotEmpty);
        final mainContact = emergency.isEmpty ? null : emergency.first;
        final phone = mainContact?['phone']?.toString().trim();
        return _buildProfile(context, name, initials, contacts, phone);
      },
    );
  }

  Widget _buildProfile(BuildContext context, String name, String initials,
      List<Map<String, dynamic>> contacts, String? phone) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Blue header
        Container(
          decoration: const BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: -60,
                top: -80,
                child: _circle(220, const Color(0x4D8FAAC3)),
              ),
              Positioned(
                right: -50,
                bottom: -70,
                child: _circle(180, const Color(0x388FAAC3)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 44,
                        child: Center(
                          child: Text('Patient profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 104,
                        height: 104,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blue, width: 4),
                        ),
                        child: Text(initials,
                            style: const TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 34,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 12),
                      Text(name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('Age not provided'),
                          _chip('Condition not provided'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // Details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person_outline, 'Full name', name),
                    const Divider(height: 1, color: AppColors.softBlue),
                    _infoRow(Icons.cake_outlined, 'Age', 'Not provided'),
                    const Divider(height: 1, color: AppColors.softBlue),
                    _infoRow(
                        Icons.favorite_border_rounded, 'Condition', 'Not provided'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Main contact
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Main contact',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greenText)),
                          const SizedBox(height: 2),
                          Text(phone ?? 'No emergency contact with a phone number',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                        ],
                      ),
                    ),
                    if (phone != null)
                      CircleIconButton(
                        icon: Icons.call_outlined,
                        tooltip: 'Call main contact',
                        background: AppColors.green,
                        color: Colors.white,
                        onPressed: () => callNumber(context, phone),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Familiar faces
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onOpenContacts,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const IconBadge(
                          icon: Icons.people_outline,
                          background: AppColors.lightGreen,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Familiar faces',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink)),
                              const SizedBox(height: 2),
                              Text(
                                contacts.isEmpty
                                    ? 'Add people $name knows'
                                    : '${contacts.length} '
                                    '${contacts.length == 1 ? 'person' : 'people'} $name knows',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.deepBlue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  static Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x29FFFFFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500)),
  );

  static Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        IconBadge(icon: icon),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink)),
          ],
        )),
      ],
    ),
  );
}
