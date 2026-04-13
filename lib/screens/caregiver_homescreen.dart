import 'package:flutter/material.dart';
import 'patient_info_screen.dart';
import 'caregiver_medications_screen.dart';
import 'caregiver_tasks_screen.dart';
import 'caregiver_emergency_screen.dart'; // ✅ IMPORTANT

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),

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

                // Patient Info
                _buildButton(
                  text: "Patient Info",
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
              ],
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
  }) {
    return Center(
      child: SizedBox(
        width: 350,
        child: GestureDetector(
          onTap: onTap,
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
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}