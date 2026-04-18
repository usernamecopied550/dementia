import 'package:flutter/material.dart';
import 'package:dementia/models/medication.dart';
import 'package:dementia/data/app_data.dart';

class CaregiverMedicationsScreen extends StatefulWidget {
  const CaregiverMedicationsScreen({super.key});

  @override
  State<CaregiverMedicationsScreen> createState() =>
      _CaregiverMedicationsScreenState();
}

class _CaregiverMedicationsScreenState
    extends State<CaregiverMedicationsScreen> {

  List<Medication> meds = AppData.medications;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ add default data only once
    if (meds.isEmpty) {
      meds.addAll([
        Medication(name: "Paracetamol", time: "10:00 am"),
        Medication(name: "Vitamin D", time: "08:00 am", taken: true),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text(
          "Medications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SafeArea(
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
                  statusColor: med.taken ? Colors.green : Colors.red,

                  // ✅ toggle
                  onTap: () {
                    setState(() {
                      med.taken = !med.taken;
                    });
                  },

                  // 🔥 DELETE
                  onDelete: () {
                    setState(() {
                      meds.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),

      // ✅ ADD MEDICATION POPUP
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add Medication"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: "Medicine Name"),
                    ),
                    TextField(
                      controller: timeController,
                      decoration:
                      const InputDecoration(labelText: "Time (e.g. 08:00 am)"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        meds.add(
                          Medication(
                            name: nameController.text,
                            time: timeController.text,
                          ),
                        );
                      });

                      nameController.clear();
                      timeController.clear();

                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔥 UPDATED CARD WITH DELETE BUTTON
  Widget medicationCard({
    required String medicine,
    required String time,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
    required VoidCallback onDelete,
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

              // 🔥 TITLE + DELETE BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Medicine: $medicine",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
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