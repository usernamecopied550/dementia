import 'package:flutter/material.dart';

class PatientEmergencyScreen extends StatefulWidget {
  const PatientEmergencyScreen({super.key});

  @override
  State<PatientEmergencyScreen> createState() => _PatientEmergencyScreenState();
}

class _PatientEmergencyScreenState extends State<PatientEmergencyScreen> {
  bool alertSent = false;

  void sendAlert() {
    setState(() {
      alertSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "I Need Help",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 🔴 Big Button
              GestureDetector(
                onTap: sendAlert,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (alertSent)
                const Text(
                  "Help request sent!",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}