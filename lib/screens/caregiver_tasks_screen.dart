import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class CaregiverTasksScreen extends StatefulWidget {
  const CaregiverTasksScreen({super.key});

  @override
  State<CaregiverTasksScreen> createState() =>
      _CaregiverTasksScreenState();
}

class _CaregiverTasksScreenState
    extends State<CaregiverTasksScreen> {

  Future<String?> getPatientId() async {
    final supabase = Supabase.instance.client;
    final caregiverId = supabase.auth.currentUser?.id;

    if (caregiverId == null) {
      return null;
    }

    final relationship = await supabase
        .from('caregiver_patients')
        .select('patient_id')
        .eq('caregiver_id', caregiverId)
        .maybeSingle();

    return relationship?['patient_id'] as String?;
  }

  Future<void> saveTask({
    required String title,
    required TimeOfDay time,
    required bool isRecurring,
    required DateTime date,
  }) async {
    final supabase = Supabase.instance.client;
    final caregiverId = supabase.auth.currentUser?.id;
    final patientId = await getPatientId();

    if (caregiverId == null || patientId == null) {
      throw Exception('No linked patient found.');
    }

    // Convert time to HH:mm:ss for Supabase
    final scheduledTime =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';

    // One-time tasks need a date; daily tasks do not
    final scheduledDate = isRecurring
        ? null
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await supabase.from('tasks').insert({
      'caregiver_id': caregiverId,
      'patient_id': patientId,
      'title': title.trim(),
      'scheduled_time': scheduledTime,
      'scheduled_date': scheduledDate,
      'is_recurring': isRecurring,
    });
  }

  Future<void> deleteTask(int taskId) async {
    final supabase = Supabase.instance.client;
    final caregiverId = supabase.auth.currentUser?.id;

    if (caregiverId == null) {
      throw Exception('Not logged in.');
    }

    await supabase
        .from('tasks')
        .delete()
        .eq('id', taskId)
        .eq('caregiver_id', caregiverId);
  }

  Future<void> confirmDeleteTask(int taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text(
          'Are you sure you want to delete this task? '
              'It will also disappear from the patient’s tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await deleteTask(taskId);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete task: $error'),
        ),
      );
    }
  }

  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    bool isRecurring = true;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        hintText: 'e.g. Eat breakfast',
                      ),
                    ),

                    const SizedBox(height: 20),

                    ListTile(
                      title: const Text('Time'),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (time != null) {
                          setDialogState(() {
                            selectedTime = time;
                          });
                        }
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Repeat Daily'),
                      value: isRecurring,
                      onChanged: (value) {
                        setDialogState(() {
                          isRecurring = value;
                        });
                      },
                    ),

                    if (!isRecurring)
                      ListTile(
                        title: const Text('Choose Date'),
                        subtitle: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (date != null) {
                            setDialogState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(

                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a task name')),
                      );
                      return;
                    }

                    try {
                      await saveTask(
                        title: titleController.text,
                        time: selectedTime,
                        isRecurring: isRecurring,
                        date: selectedDate,
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      if (!mounted) return;
                      setState(() {});

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Task saved successfully!')),
                      );
                    }

                    catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Could not save task: $error')),
                      );
                    }
                  },

                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }
  Future<List<Map<String, dynamic>>> loadTasks() async {
    final supabase = Supabase.instance.client;
    final caregiverId = supabase.auth.currentUser?.id;

    if (caregiverId == null) {
      return [];
    }

    final response = await supabase
        .from('tasks')
        .select()
        .eq('caregiver_id', caregiverId)
        .order('scheduled_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Set<int>> loadCompletedTaskIds() async {
    final supabase = Supabase.instance.client;
    final patientId = await getPatientId();

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

  Future<List<Map<String, dynamic>>> loadTasksWithCompletion() async {
    final tasks = await loadTasks();
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
                          child: Text('No tasks yet. Add your first task!'),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];


                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: const Color(0xFF8FA9C4),
                            child: ListTile(
                              leading: Icon(
                                task['isDone'] == true
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task['isDone'] == true
                                    ? Colors.green
                                    : Colors.black,
                                size: 28,
                              ),
                              title: Text(
                                task['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  decoration: task['isDone'] == true
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                'Time: ${task['scheduled_time'].toString().substring(0, 5)}',
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task['isDone'] == true ? 'Completed' : 'Pending',
                                    style: TextStyle(
                                      color: task['isDone'] == true
                                          ? Colors.green.shade900
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete task',
                                    onPressed: () {
                                      confirmDeleteTask((task['id'] as num).toInt());
                                    },
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


                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: showAddTaskDialog,
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