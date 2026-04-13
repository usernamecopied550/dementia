import 'package:flutter/material.dart';
import '../models/task.dart';
class CaregiverTasksScreen extends StatefulWidget {
  const CaregiverTasksScreen({super.key});

  @override
  State<CaregiverTasksScreen> createState() =>
      _CaregiverTasksScreenState();
}

class _CaregiverTasksScreenState
    extends State<CaregiverTasksScreen> {

  List<Map<String, dynamic>> tasks = [
    {"title": "Take medication", "done": false},
    {"title": "Eat Breakfast", "done": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Daily Tasks"),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: SizedBox(
                          width: 350,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA9C4),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [

                                Row(
                                  children: [
                                    Checkbox(
                                      value: tasks[index]["done"],
                                      onChanged: (value) {
                                        setState(() {
                                          tasks[index]["done"] = value;
                                        });
                                      },
                                    ),
                                    Text(
                                      tasks[index]["title"],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                const Icon(Icons.delete),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {},
                  child: const Text("+ Add Task"),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}