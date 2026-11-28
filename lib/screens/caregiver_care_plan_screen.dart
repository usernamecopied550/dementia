import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/care_item.dart';
import '../services/caregiver_task_service.dart';
import '../widgets/caregiver_widgets.dart';

/// Scheduled tasks in one timeline.
class CaregiverCarePlanScreen extends StatefulWidget {
  const CaregiverCarePlanScreen({super.key});

  @override
  State<CaregiverCarePlanScreen> createState() =>
      _CaregiverCarePlanScreenState();
}

class _CaregiverCarePlanScreenState extends State<CaregiverCarePlanScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = CaregiverTaskService.loadTasksWithCompletion();
  }

  // FIXED: block body { } so setState doesn't return a Future
  void _reloadTasks() {
    setState(() {
      _tasksFuture = CaregiverTaskService.loadTasksWithCompletion();
    });
  }

  String get _todayLabel {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    final d = DateTime.now();
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  // ---------- Add ----------

  Future<void> _showAddTaskDialog() async {
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('Add task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task name',
                        hintText: 'e.g. Eat breakfast',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
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
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Repeat daily'),
                      value: isRecurring,
                      onChanged: (value) => setDialogState(() {
                        isRecurring = value;
                      }),
                    ),
                    if (!isRecurring)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date'),
                        subtitle: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
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
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deepBlue),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a task name')),
                      );
                      return;
                    }
                    try {
                      await CaregiverTaskService.saveTask(
                        title: titleController.text,
                        time: selectedTime,
                        isRecurring: isRecurring,
                        date: selectedDate,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      _reloadTasks();
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Task saved!')),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Could not save task: $error')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    titleController.dispose();
  }

  // ---------- Delete tasks (Supabase) ----------

  Future<void> _deleteTask(CareItem item) async {
    if (item.taskId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await CaregiverTaskService.deleteTask(item.taskId!);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete task: $error')),
        );
      }
    }
    if (mounted) _reloadTasks();
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add task',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final tasks = snapshot.data ?? [];
            final now = DateTime.now();
            final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
            final todayTasks = tasks.where((t) => t['is_recurring'] == true ||
                t['scheduled_date']?.toString() == today).toList();
            final all = CareItem.combine([], tasks);
            final done = todayTasks.where((t) => t['isDone'] == true).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      PageHeader(subtitle: _todayLabel, title: 'Care plan'),
                      const SizedBox(height: 16),
                      if (!loading && !snapshot.hasError)
                        _ProgressCard(done: done, total: todayTasks.length),
                      const SizedBox(height: 16),
                      const Text('Scheduled tasks'),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildList(all, loading, snapshot.hasError, tasks),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<CareItem> shown, bool loading, bool hasError, List<Map<String, dynamic>> tasks) {
    if (shown.isEmpty) {
      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          hasError ? 'Could not load tasks.' : 'Nothing here yet. Tap Add!',
          style: const TextStyle(color: AppColors.muted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _reloadTasks();
        await _tasksFuture.catchError((_) => <Map<String, dynamic>>[]);
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = shown[index];
          final task = tasks.firstWhere((t) => t['id'] == item.taskId,
              orElse: () => <String, dynamic>{});
          final schedule = task['is_recurring'] == true
              ? 'Daily' : (task['scheduled_date'] ?? '').toString();
          return _CareRow(
            item: item,
            schedule: schedule,
            onDelete: () => _deleteTask(item),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done, total;

  const _ProgressCard({
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final left = total - done;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    strokeWidth: 9,
                    backgroundColor: const Color(0x738FAAC3),
                    color: AppColors.progressGreen,
                  ),
                ),
                Text('$done/$total',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? 'No plan for today yet'
                      : (left == 0
                      ? 'All done for today'
                      : '$left things left today'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _pill('Tasks $done/$total'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0x24FFFFFF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500)),
  );
}

class _CareRow extends StatelessWidget {
  final CareItem item;
  final String schedule;
  final VoidCallback? onDelete;

  const _CareRow({required this.item, required this.schedule, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final status = item.done ? 'Completed' : 'Pending';
    final statusColor = item.done ? AppColors.greenText : AppColors.muted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 46,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              item.timeLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: item.done ? 0.75 : 1,
            child: Material(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    children: [
                      IconBadge(
                        icon: Icons.checklist_rounded,
                        background:
                        AppColors.midGreen,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                decoration: item.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$schedule · $status',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor),
                            ),
                          ],
                        ),
                      ),
                      CheckDot(done: item.done),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Delete ${item.title}',
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.ink, size: 20),
                        )
                      else
                        const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}