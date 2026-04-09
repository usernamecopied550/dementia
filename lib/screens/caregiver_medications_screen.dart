import 'package:flutter/material.dart';

class CaregiverMedicationsScreen extends StatelessWidget {
  const CaregiverMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Medications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 centers vertically
          children: [
            medicationCard(
              medicine: "Paracetamol",
              time: "10:00 am",
              status: "Not Taken",
              statusColor: Colors.red,
            ),
            const SizedBox(height: 20),
            medicationCard(
              medicine: "Vitamin D",
              time: "08:00 am",
              status: "Taken",
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget medicationCard({
    required String medicine,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Center(
      child: Container(
        width: 320, // 👈 perfect centered size
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF8FA9C4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Medicine: $medicine",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Time: $time",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Status: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}