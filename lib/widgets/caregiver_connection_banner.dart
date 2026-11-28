import 'package:flutter/material.dart';
import '../services/pairing_service.dart';
import '../screens/caregiver_pairing_screen.dart';

class CaregiverConnectionBanner extends StatefulWidget {
  final VoidCallback? onConnectionChanged;

  const CaregiverConnectionBanner({
    super.key,
    this.onConnectionChanged,
  });

  @override
  State<CaregiverConnectionBanner> createState() =>
      _CaregiverConnectionBannerState();
}

class _CaregiverConnectionBannerState
    extends State<CaregiverConnectionBanner> {
  final pairingService = PairingService();

  late Future<String?> linkedPatientFuture;

  @override
  void initState() {
    super.initState();
    linkedPatientFuture =
        pairingService.getLinkedPersonName('caregiver');
  }

  void refreshConnection() {
    setState(() {
      linkedPatientFuture =
          pairingService.getLinkedPersonName('caregiver');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: linkedPatientFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return TextButton(
            onPressed: refreshConnection,
            child: const Text(
              'Could not load patient. Retry',
            ),
          );
        }

        final patientName = snapshot.data;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName == null
                              ? 'No patient linked'
                              : 'Your patient',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        if (patientName != null)
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (patientName == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CaregiverPairingScreen(),
                        ),
                      );

                      if (!mounted) return;

                      refreshConnection();
                      widget.onConnectionChanged?.call();
                    },
                    child: const Text('Link a Patient'),
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}