import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../screens/medication_screen.dart';
import '../screens/tasks_screen.dart';
import 'family_screen.dart';
import '../patient.dart';
import '../patient_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

/// 🔴 EMERGENCY SCREEN
class PatientEmergencyScreen extends StatefulWidget {
  const PatientEmergencyScreen({super.key});

  @override
  State<PatientEmergencyScreen> createState() =>
      _PatientEmergencyScreenState();
}

class _PatientEmergencyScreenState
    extends State<PatientEmergencyScreen> {
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

      // ✅🔥 THIS IS THE FIX (BACK ARROW)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

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

/// 🏠 PATIENT HOME SCREEN


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

// Keep the existing logout functionality
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not log out. Please try again.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Good Morning!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Here are your activities for today.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

// Temporary example.
// Later this will come from Supabase.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "YOUR NEXT ACTIVITY",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Eat breakfast",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "9:00 AM",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

// TODAY'S TASKS
                  CustomButton(
                    text: "Today's Tasks",
                    imagePath: 'assets/images/calendar.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const TasksScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

// EMERGENCY CONTACTS
                  CustomButton(
                    text: "Emergency Contacts",
                    imagePath: 'assets/images/alert.png',
                    onPressed: () {
// We will create this screen next.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Emergency Contacts coming soon!",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

// FAMILY (OPTIONAL FEATURE)
                  CustomButton(
                    text: "My Family",
                    imagePath: 'assets/images/family.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const FamilyScreen(),
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
    );
  }
}
