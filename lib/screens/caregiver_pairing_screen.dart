import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pairing_service.dart';

class CaregiverPairingScreen extends StatefulWidget {
  const CaregiverPairingScreen({super.key});

  @override
  State<CaregiverPairingScreen> createState() =>
      _CaregiverPairingScreenState();
}

class _CaregiverPairingScreenState
    extends State<CaregiverPairingScreen> {
  final pairingService = PairingService();
  final codeController = TextEditingController();

  bool isLoading = false;

  Future<void> linkPatient() async {
    final code = codeController.text.trim();

    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      showMessage('Please enter a valid six-digit code.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await pairingService.redeemCode(code);

      if (!mounted) return;

      switch (result) {
        case 'success':
          showMessage('Patient successfully linked!');
          Navigator.pop(context, true);
          break;

        case 'invalid_code':
          showMessage('Invalid or expired pairing code.');
          break;

        case 'already_linked':
          showMessage('You already have a linked patient.');
          break;
        case 'patient_already_linked':
          showMessage('This patient already has a linked caregiver.');
          break;

        case 'too_many_attempts':
          showMessage(
            'Too many attempts. Please try again later.',
          );
          break;

        case 'unauthorized':
          showMessage('Only caregivers can link patients.');
          break;

        default:
          showMessage('Something went wrong.');
      }
    } catch (e) {
      if (!mounted) return;

      showMessage('Could not link patient. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Link a Patient'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect with your patient',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the six-digit pairing code generated '
                    'on your patient\'s device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 6,
                ),
                decoration: const InputDecoration(
                  labelText: 'Pairing code',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : linkPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    'Link Patient',
                    style: TextStyle(fontSize: 18),
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