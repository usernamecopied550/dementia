import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../data/app_data.dart';
import '../models/care_item.dart';
import '../models/medication.dart';
import '../services/task_service.dart';
import '../widgets/caregiver_widgets.dart';

/// Medications + daily tasks in one timeline.
class CaregiverCarePlanScreen extends StatefulWidget {
  const CaregiverCarePlanScreen({super.key});

  @override
  State<CaregiverCarePlanScreen> createState() =>
      _CaregiverCarePlanScreenState();
}

class _CaregiverCarePlanScreenState extends State<CaregiverCarePlanScreen> {
  String _filter = 'all'; // all | med | task
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = TaskService.loadTasksWithCompletion();
  }

  // FIXED: block body { } so setState doesn't return a Future
  void _reloadTasks() {
    setState(() {
      _tasksFuture = TaskService.loadTasksWithCompletion();
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

  void _showAddChoice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What do you want to add?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                const SizedBox(height: 16),
                _choiceTile(
                  icon: Icons.medication_outlined,
                  title: 'Medication',
                  color: AppColors.blue,
                  badge: AppColors.lightBlue,
                  iconColor: AppColors.deepBlue,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAddMedicationDialog();
                  },
                ),
                const SizedBox(height: 10),
                _choiceTile(
                  icon: Icons.checklist_rounded,
                  title: 'Task',
                  color: AppColors.lightGreen,
                  badge: AppColors.midGreen,
                  iconColor: AppColors.green,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAddTaskDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String title,
    required Color color,
    required Color badge,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconBadge(icon: icon, background: badge, color: iconColor),
              const SizedBox(width: 14),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMedicationDialog() async {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('Add medication'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine name',
                      hintText: 'e.g. Paracetamol',
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deepBlue),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final h = selectedTime.hourOfPeriod == 0
                        ? 12
                        : selectedTime.hourOfPeriod;
                    final m = selectedTime.minute.toString().padLeft(2, '0');
                    final period =
                    selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
                    setState(() {
                      AppData.medications.add(Medication(
                        name: nameController.text.trim(),
                        time: '$h:$m $period',
                      ));
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
    nameController.dispose();
  }

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
                      await TaskService.saveTask(
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

  // ---------- Tick / delete tasks (Supabase) ----------

  Future<void> _toggleTask(CareItem item) async {
    if (item.taskId == null) return;
    try {
      await TaskService.toggleTaskCompletion(item.taskId!, item.done);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update task: $error')),
        );
      }
    }
    if (mounted) _reloadTasks();
  }

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
      await TaskService.deleteTask(item.taskId!);
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
        onPressed: _showAddChoice,
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final tasks = snapshot.data ?? [];
            final all = CareItem.combine(AppData.medications, tasks);
            final shown = all
                .where((i) =>
            _filter == 'all' ||
                (_filter == 'med' && i.isMed) ||
                (_filter == 'task' && !i.isMed))
                .toList();

            final meds = all.where((i) => i.isMed);
            final tsk = all.where((i) => !i.isMed);
            final done = all.where((i) => i.done).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      PageHeader(subtitle: _todayLabel, title: 'Care plan'),
                      const SizedBox(height: 16),
                      _ProgressCard(
                        done: done,
                        total: all.length,
                        medsDone: meds.where((i) => i.done).length,
                        medsTotal: meds.length,
                        tasksDone: tsk.where((i) => i.done).length,
                        tasksTotal: tsk.length,
                      ),
                      const SizedBox(height: 16),
                      _FilterBar(
                        value: _filter,
                        onChanged: (v) => setState(() {
                          _filter = v;
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildList(shown, loading, snapshot.hasError),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<CareItem> shown, bool loading, bool hasError) {
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
      onRefresh: () async => _reloadTasks(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = shown[index];
          return _CareRow(
            item: item,
            onToggle: item.isMed
                ? () => setState(() {
              item.med!.taken = !item.med!.taken;
            })
                : () => _toggleTask(item),
            onDelete: item.isMed
                ? () => setState(() {
              AppData.medications.remove(item.med);
            })
                : () => _deleteTask(item),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done, total, medsDone, medsTotal, tasksDone, tasksTotal;

  const _ProgressCard({
    required this.done,
    required this.total,
    required this.medsDone,
    required this.medsTotal,
    required this.tasksDone,
    required this.tasksTotal,
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
                    _pill('Meds $medsDone/$medsTotal'),
                    _pill('Tasks $tasksDone/$tasksTotal'),
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

class _FilterBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _FilterBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = {'all': 'All', 'med': 'Medications', 'task': 'Tasks'};
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: options.entries.map((e) {
          final selected = e.key == value;
          return Expanded(
            child: Material(
              color: selected ? AppColors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(e.key),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CareRow extends StatelessWidget {
  final CareItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const _CareRow({required this.item, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isMed = item.isMed;
    final status = item.done
        ? (isMed ? 'Taken' : 'Completed')
        : (isMed ? 'Not taken' : 'Pending');
    final statusColor = isMed
        ? (item.done ? const Color(0xFF14401A) : AppColors.ink)
        : (item.done ? AppColors.greenText : AppColors.muted);

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
              color: isMed ? AppColors.blue : AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    children: [
                      IconBadge(
                        icon: isMed
                            ? Icons.medication_outlined
                            : Icons.checklist_rounded,
                        background:
                        isMed ? AppColors.lightBlue : AppColors.midGreen,
                        color: isMed ? AppColors.deepBlue : AppColors.green,
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
                              '${isMed ? 'Medication' : 'Task'} · $status',
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