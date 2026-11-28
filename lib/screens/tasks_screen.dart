import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/colors.dart';
import '../widgets/caregiver_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = loadTasksWithCompletion();
  }

  // FIXED: block body { } so setState doesn't return a Future
  void _reload() {
    setState(() {
      _future = loadTasksWithCompletion();
    });
  }

  String get _todayString {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  Future<List<Map<String, dynamic>>> loadPatientTasks() async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;
    if (patientId == null) return [];

    final response = await supabase
        .from('tasks')
        .select()
        .eq('patient_id', patientId)
        .or('is_recurring.eq.true,scheduled_date.eq.$_todayString')
        .order('scheduled_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Set<int>> loadCompletedTaskIds() async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;
    if (patientId == null) return {};

    final response = await supabase
        .from('task_completions')
        .select('task_id')
        .eq('patient_id', patientId)
        .eq('completed_date', _todayString);

    return response.map<int>((row) => (row['task_id'] as num).toInt()).toSet();
  }

  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    final supabase = Supabase.instance.client;
    final patientId = supabase.auth.currentUser?.id;
    if (patientId == null) throw Exception('Not logged in.');

    if (isCompleted) {
      await supabase
          .from('task_completions')
          .delete()
          .eq('task_id', taskId)
          .eq('patient_id', patientId)
          .eq('completed_date', _todayString);
    } else {
      await supabase.from('task_completions').insert({
        'task_id': taskId,
        'patient_id': patientId,
        'completed_date': _todayString,
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadTasksWithCompletion() async {
    final tasks = await loadPatientTasks();
    final completedIds = await loadCompletedTaskIds();
    for (final task in tasks) {
      task['isDone'] = completedIds.contains((task['id'] as num).toInt());
    }
    return tasks;
  }

  Future<void> _toggle(Map<String, dynamic> task) async {
    try {
      await toggleTaskCompletion(
        (task['id'] as num).toInt(),
        task['isDone'] == true,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update: $error'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
    if (mounted) _reload(); // always refresh
  }

  String _time(dynamic t) {
    final s = (t ?? '').toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'My tasks',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load tasks.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.muted),
                        ),
                      );
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nothing planned today',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      );
                    }

                    final done = tasks.where((t) => t['isDone'] == true).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$done of ${tasks.length} done',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final isDone = task['isDone'] == true;

                              return Material(
                                color: isDone
                                    ? AppColors.lightGreen
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () => _toggle(task),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 22),
                                    child: Row(
                                      children: [
                                        CheckDot(done: isDone, size: 42),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            (task['title'] ?? '').toString(),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: isDone
                                                  ? AppColors.greenText
                                                  : AppColors.ink,
                                              decoration: isDone
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _time(task['scheduled_time']),
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            color: isDone
                                                ? AppColors.greenText
                                                : AppColors.deepBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}