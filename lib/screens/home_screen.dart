import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../screens/medication_screen.dart';
import '../screens/tasks_screen.dart';
import 'family_screen.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 400,
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView( // ✅ FIX OVERFLOW
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      "Good\nMorning",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Column(
                      children: [
                        Text(
                          "Next Medication: 10:00 am",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Status: Not taken yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    CustomButton(
                      text: "Take medication",
                      imagePath: 'assets/images/pill.png',
                    ),

                    CustomButton(
                      text: "Today's Tasks",
                      imagePath: 'assets/images/calendar.png',
                        onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                         builder: (context) => const TasksScreen(),
                      ),
                    );
                  },
              ),


                    CustomButton(
                      text: "Family",
                      imagePath: 'assets/images/family.png',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FamilyScreen(),
                          ),
                        );
                      },
                    ),

                    CustomButton(
                      text: "I Need Help",
                      imagePath: 'assets/images/alert.png',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientEmergencyScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}