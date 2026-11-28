import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase task logic (used by the dashboard and the care plan).
class CaregiverTaskService {
  static SupabaseClient get _db => Supabase.instance.client;

  static String get _todayString {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  static Future<String?> getPatientId() async {
    final caregiverId = _db.auth.currentUser?.id;
    if (caregiverId == null) return null;

    final relationship = await _db
        .from('caregiver_patients')
        .select('patient_id')
        .eq('caregiver_id', caregiverId)
        .maybeSingle();

    return relationship?['patient_id'] as String?;
  }

  static Future<void> saveTask({
    required String title,
    required TimeOfDay time,
    required bool isRecurring,
    required DateTime date,
  }) async {
    final caregiverId = _db.auth.currentUser?.id;
    final patientId = await getPatientId();

    if (caregiverId == null || patientId == null) {
      throw Exception('No linked patient found.');
    }

    final scheduledTime = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';

    final scheduledDate = isRecurring
        ? null
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await _db.from('tasks').insert({
      'caregiver_id': caregiverId,
      'patient_id': patientId,
      'title': title.trim(),
      'scheduled_time': scheduledTime,
      'scheduled_date': scheduledDate,
      'is_recurring': isRecurring,
    });
  }

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final caregiverId = _db.auth.currentUser?.id;
    if (caregiverId == null) return [];

    final response = await _db
        .from('tasks')
        .select()
        .eq('caregiver_id', caregiverId)
        .order('scheduled_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Set<int>> loadCompletedTaskIds() async {
    final patientId = await getPatientId();
    if (patientId == null) return {};

    final response = await _db
        .from('task_completions')
        .select('task_id')
        .eq('patient_id', patientId)
        .eq('completed_date', _todayString);

    return response.map<int>((row) => (row['task_id'] as num).toInt()).toSet();
  }

  static Future<List<Map<String, dynamic>>> loadTasksWithCompletion() async {
    final tasks = await loadTasks();
    final completedIds = await loadCompletedTaskIds();

    for (final task in tasks) {
      final taskId = (task['id'] as num).toInt();
      task['isDone'] = completedIds.contains(taskId);
    }
    return tasks;
  }

  /// Caregiver ticks / unticks a task for today (for the patient).
  static Future<void> toggleTaskCompletion(int taskId, bool isDone) async {
    final patientId = await getPatientId();
    if (patientId == null) throw Exception('No linked patient found.');

    if (isDone) {
      await _db
          .from('task_completions')
          .delete()
          .eq('task_id', taskId)
          .eq('patient_id', patientId)
          .eq('completed_date', _todayString);
    } else {
      await _db.from('task_completions').insert({
        'task_id': taskId,
        'patient_id': patientId,
        'completed_date': _todayString,
      });
    }
  }

  /// Caregiver deletes a task completely.
  static Future<void> deleteTask(int taskId) async {
    await _db.from('task_completions').delete().eq('task_id', taskId);
    await _db.from('tasks').delete().eq('id', taskId);
  }
}
