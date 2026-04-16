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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,

        // 🔥 FORCE BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(height: 40),

                  const Text(
                    "I Need Help",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔴 Big Emergency Button
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
        ),
      ),
    );
  }
}