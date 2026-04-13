import 'package:flutter/material.dart';

class CaregiverEmergencyScreen extends StatelessWidget {
  const CaregiverEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Emergency"),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "Emergency Activated",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "The patient has requested help",
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    onPressed: () {
                      // 👉 later we add call logic
                    },
                    child: const Text(
                      "Call Patient",
                      style: TextStyle(fontSize: 18),
                    ),
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