import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> loadTasksWithCompletion() async {
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      throw Exception('Patient is not logged in.');
    }

    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    // Retrieve today's scheduled tasks
    final response = await supabase
        .from('tasks')
        .select()
        .eq('patient_id', patientId)
        .or('is_recurring.eq.true,scheduled_date.eq.$todayString')
        .order('scheduled_time', ascending: true);

    final tasks = List<Map<String, dynamic>>.from(response);

    // Retrieve today's completed tasks
    final completedResponse = await supabase
        .from('task_completions')
        .select('task_id')
        .eq('patient_id', patientId)
        .eq('completed_date', todayString);

    final completedIds = completedResponse
        .map<int>((row) => (row['task_id'] as num).toInt())
        .toSet();

    // Attach completion status to each task
    for (final task in tasks) {
      final taskId = (task['id'] as num).toInt();
      task['isDone'] = completedIds.contains(taskId);
    }

    return tasks;
  }
}