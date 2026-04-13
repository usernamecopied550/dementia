import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> tasks = [
    {"title": "Take Medication", "done": false},
    {"title": "Eat Breakfast", "done": false},
    {"title": "Go for a walk", "done": false},
    {"title": "Drink Water", "done": false},
  ];

  void toggleTask(int index) {
    setState(() {
      tasks[index]["done"] = !tasks[index]["done"];
    });
  }

  void addTask() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter task name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    tasks.add({
                      "title": controller.text.trim(),
                      "done": false,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔙 Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // 🔹 Title with calendar image
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/calendar.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Tasks",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔹 Task List
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA9C4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [

                                // Checkbox
                                GestureDetector(
                                  onTap: () => toggleTask(index),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: tasks[index]["done"]
                                          ? Colors.green
                                          : Colors.white,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: tasks[index]["done"]
                                        ? const Icon(Icons.check,
                                        size: 18,
                                        color: Colors.white)
                                        : null,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // Task text
                                Expanded(
                                  child: Text(
                                    tasks[index]["title"],
                                    style: TextStyle(
                                      fontSize: 18,
                                      decoration: tasks[index]["done"]
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Add Task Button
                  GestureDetector(
                    onTap: addTask,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA9C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text(
                            "Add Task",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}