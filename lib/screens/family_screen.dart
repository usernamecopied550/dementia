import 'package:flutter/material.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: Container(
          width: 400,
          color: Colors.grey[200],

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔙 Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 10),

                  // 🔹 CENTERED TITLE + IMAGE
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/family.png',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Family",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

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

  // 🔹 Member Card
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