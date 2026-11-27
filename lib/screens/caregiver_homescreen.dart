import 'package:flutter/material.dart';
import 'patient_info_screen.dart';
import 'caregiver_medications_screen.dart';
import 'caregiver_tasks_screen.dart';
import 'caregiver_emergency_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pairing_service.dart';
import 'welcome_screen.dart';
import '../widgets/caregiver_connection_banner.dart';


class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() =>
      _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState
    extends State<CaregiverHomeScreen> {
  final pairingService = PairingService();

  bool isPatientLinked = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      final patientName =
      await pairingService.getLinkedPersonName('caregiver');

      if (!mounted) return;

      setState(() {
        isPatientLinked = patientName != null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPatientLinked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const Text(
                    "Caregiver\nDashboard",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),
                  CaregiverConnectionBanner(
                    onConnectionChanged: checkConnection,
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 16),

                  // Patient Info
                  _buildButton(
                    text: "Patient Info",
                    isEnabled: isPatientLinked,
                    image: "assets/images/calendar.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const PatientInfoScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Medications
                  _buildButton(
                    text: "Medications",
                    isEnabled: isPatientLinked,
                    image: "assets/images/pill.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CaregiverMedicationsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Daily Tasks
                  _buildButton(
                    text: "Daily Tasks",
                    isEnabled: isPatientLinked,
                    image: "assets/images/pin.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CaregiverTasksScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ✅ Emergency (FIXED)
                  _buildButton(
                    text: "Emergency",
                    isEnabled: isPatientLinked,
                    image: "assets/images/alert.png",
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CaregiverEmergencyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required String image,
    Color textColor = Colors.black,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Center(
      child: SizedBox(
        width: 350,
        child: GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8FAAC3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Image.asset(image, width: 50),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (!isEnabled)
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.black54,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}