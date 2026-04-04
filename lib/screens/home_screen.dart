import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../screens/medication_screen.dart';
import '../screens/tasks_screen.dart';
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
                    ),

                    CustomButton(
                      text: "I need Help",
                      imagePath: 'assets/images/alert.png',
                      isDanger: true,
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