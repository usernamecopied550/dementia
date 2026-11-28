import 'package:supabase_flutter/supabase_flutter.dart';

class PairingService {
  final supabase = Supabase.instance.client;

  // Patient generates a pairing code
  Future<String> generateCode() async {
    final response = await supabase.rpc(
      'generate_pairing_code',
    );

    return response as String;
  }

  // Caregiver submits a pairing code
  Future<String> redeemCode(String code) async {
    final response = await supabase.rpc(
      'redeem_pairing_code',
      params: {'entered_code': code.trim()},
    );

    return response as String;
  }
  // Retrieve the linked patient or caregiver
  Future<String?> getLinkedPersonName(String role) async {
    final userId = supabase.auth.currentUser!.id;

    final isPatient = role == 'patient';

    final relationship = await supabase
        .from('caregiver_patients')
        .select('caregiver_id, patient_id')
        .eq(
      isPatient ? 'patient_id' : 'caregiver_id',
      userId,
    )
        .maybeSingle();

    // No linked account
    if (relationship == null) {
      return null;
    }

    final linkedId = isPatient
        ? relationship['caregiver_id']
        : relationship['patient_id'];

    final profile = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', linkedId)
        .single();

    final name = profile['full_name'] as String?;

    return name == null || name.trim().isEmpty
        ? (isPatient ? 'Caregiver' : 'Patient')
        : name;
  }
}