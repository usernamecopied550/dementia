import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {

  Future<List<Map<String, dynamic>>> loadPatientTasks() async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      return [];
    }

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final response = await supabase
        .from('tasks')
        .select()
        .eq('patient_id', patientId)
        .or('is_recurring.eq.true,scheduled_date.eq.$todayString')
        .order('scheduled_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Set<int>> loadCompletedTaskIds() async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) return {};

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final response = await supabase
        .from('task_completions')
        .select('task_id')
        .eq('patient_id', patientId)
        .eq('completed_date', todayString);

    return response
        .map<int>((row) => (row['task_id'] as num).toInt())
        .toSet();
  }

  Future<void> toggleTaskCompletion(
      int taskId,
      bool isCompleted,
      ) async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) return;

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    if (isCompleted) {
      // Remove today's completion if Mary unchecks a task
      await supabase
          .from('task_completions')
          .delete()
          .eq('task_id', taskId)
          .eq('patient_id', patientId)
          .eq('completed_date', todayString);
    } else {
      // Save today's completion if Mary checks a task
      await supabase.from('task_completions').insert({
        'task_id': taskId,
        'patient_id': patientId,
        'completed_date': todayString,
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadTasksWithCompletion() async {
    final tasks = await loadPatientTasks();
    final completedIds = await loadCompletedTaskIds();

    for (final task in tasks) {
      final taskId = (task['id'] as num).toInt();
      task['isDone'] = completedIds.contains(taskId);
    }

    return tasks;
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

                  // 🔹 Title
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: loadTasksWithCompletion(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Could not load tasks.'),
                    );
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks scheduled for today.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8FA9C4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [

                              GestureDetector(
                                onTap: () async {
                                  final taskId = (task['id'] as num).toInt();
                                  final isCompleted = task['isDone'] == true;

                                  try {
                                    await toggleTaskCompletion(taskId, isCompleted);

                                    if (!mounted) return;
                                    setState(() {});
                                  } catch (error) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Could not update task: $error'),
                                      ),
                                    );
                                  }
                                },
                                child: Icon(
                                  task['isDone'] == true
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: task['isDone'] == true
                                      ? Colors.green
                                      : Colors.black,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Text(
                                  task['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    decoration: task['isDone'] == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),

                              Text(
                                task['scheduled_time']
                                    .toString()
                                    .substring(0, 5),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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