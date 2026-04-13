import 'package:flutter/material.dart';
import 'package:dimentia/models/medication.dart';
import 'package:dimentia/data/app_data.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {

  List<Medication> meds = AppData.medications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text(
          "My Medications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SafeArea(
        child: meds.isEmpty
            ? const Center(child: Text("No medications assigned"))
            : ListView.builder(
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final med = meds[index];

            return Column(
              children: [
                medicationCard(
                  medicine: med.name,
                  time: med.time,
                  status: med.taken ? "Taken" : "Not Taken",
                  statusColor:
                  med.taken ? Colors.green : Colors.red,
                  onTap: () {
                    setState(() {
                      med.taken = !med.taken;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ NO DELETE HERE
  Widget medicationCard({
    required String medicine,
    required String time,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 320,
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
      ),
    );
  }
}