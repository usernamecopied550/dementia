import 'package:flutter/material.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: Container(
          width: 400, // same width as other screens
          color: Colors.grey[200],

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔹 Title Row
                  Row(
                    children: const [
                      Text(
                        "👨‍👩‍👧",
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Family",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Family Members
                  buildMember("Mom"),
                  buildMember("Dad"),
                  buildMember("Daughter"),
                  buildMember("Son"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Widget for each member
  Widget buildMember(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF8FAAC6),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          const Icon(Icons.person, size: 30, color: Colors.blue),

          const SizedBox(width: 15),

          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}