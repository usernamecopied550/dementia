import 'package:flutter/material.dart';
import '../services/pairing_service.dart';

class PatientPairingScreen extends StatefulWidget {
  const PatientPairingScreen({super.key});

  @override
  State<PatientPairingScreen> createState() =>
      _PatientPairingScreenState();
}

class _PatientPairingScreenState
    extends State<PatientPairingScreen> {
  final pairingService = PairingService();

  String? pairingCode;
  bool isLoading = false;

  Future<void> generateCode() async {
    setState(() => isLoading = true);

    try {
      final code = await pairingService.generateCode();

      if (!mounted) return;

      setState(() => pairingCode = code);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not generate a code. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Link a Caregiver'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect with your caregiver',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Generate a code and show it to your caregiver.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),

              if (pairingCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    pairingCode!,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Code valid for 15 minutes after generation',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
              ],

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : generateCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    pairingCode == null
                        ? 'Generate Code'
                        : 'Generate New Code',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}