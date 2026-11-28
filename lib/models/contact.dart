import 'dart:typed_data';

/// A person the patient knows (stored in the Supabase `contacts` table).
class Contact {
  final String? id;
  final String name;
  final String phone;
  final String relation;
  final String? note;
  final String? photoPath;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final bool isEmergency;

  const Contact({
    this.id,
    required this.name,
    this.phone = '',
    required this.relation,
    this.note,
    this.photoPath,
    this.photoUrl,
    this.photoBytes,
    this.isEmergency = false,
  });

  factory Contact.fromMap(Map<String, dynamic> m, {String? photoUrl}) {
    final rel = (m['relationship'] as String?) ?? 'other';
    return Contact(
      id: m['id'] as String?,
      name: (m['full_name'] as String?) ?? '',
      phone: (m['phone'] as String?) ?? '',
      relation: rel.isEmpty ? 'Other' : rel[0].toUpperCase() + rel.substring(1),
      note: m['reminder_note'] as String?,
      photoPath: m['photo_path'] as String?,
      photoUrl: photoUrl,
      isEmergency: (m['is_emergency'] as bool?) ?? false,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}