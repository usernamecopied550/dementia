import 'package:flutter/material.dart';
import 'package:dementia/models/medication.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Medication> meds = [];
  Future<void> loadMedications() async {
    final data = await Supabase.instance.client
        .from('medications')
        .select();

    final loadedMeds = data.map<Medication>((row) {
      return Medication(
        id: row['id'],
        name: row['name'] ?? '',
        time: row['scheduled_time'] ?? '',
        taken: false,
      );
    }).toList();

    setState(() {
      meds = loadedMeds;
    });
  }
  @override
  void initState() {
    super.initState();
    loadMedications();
  }

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

        // 🔥 FORCE BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: meds.isEmpty
            ? const Center(
          child: Text(
            "No medications assigned",
            style: TextStyle(fontSize: 18),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
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
      ),
    );
  }

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            width: double.infinity,
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
                // 🔥 ICON + TITLE
                Row(
                  children: [
                    const Icon(Icons.medication, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medicine,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Time: $time",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Status: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

                const SizedBox(height: 8),

                const Text(
                  "Tap to mark as taken",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
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