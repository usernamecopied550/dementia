import 'medication.dart';

/// One row in the caregiver's Care plan: either a medication or a task.
class CareItem {
  final String title;
  final int minutes; // minutes since midnight, used for sorting
  final bool isMed;
  final bool done;
  final Medication? med; // set for medications (so we can toggle / delete)
  final int? taskId; // NEW: set for tasks (so we can toggle / delete)

  CareItem({
    required this.title,
    required this.minutes,
    required this.isMed,
    required this.done,
    this.med,
    this.taskId,
  });

  String get timeLabel {
    if (minutes >= 24 * 60) return '--:--';
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Understands "10:00 AM", "6:00 PM", "08:00 am", "09:00:00", "21:00".
  static int parseMinutes(String raw) {
    final s = raw.trim().toLowerCase();
    final match = RegExp(r'(\d{1,2})(?::(\d{2}))?').firstMatch(s);
    if (match == null) return 24 * 60;
    var hour = int.parse(match.group(1)!);
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    if (s.contains('pm') && hour < 12) hour += 12;
    if (s.contains('am') && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  static List<CareItem> combine(
      List<Medication> meds,
      List<Map<String, dynamic>> tasks,
      ) {
    final items = <CareItem>[
      for (final m in meds)
        CareItem(
          title: m.name,
          minutes: parseMinutes(m.time),
          isMed: true,
          done: m.taken,
          med: m,
        ),
      for (final t in tasks)
        CareItem(
          title: (t['title'] ?? '').toString(),
          minutes: parseMinutes((t['scheduled_time'] ?? '').toString()),
          isMed: false,
          done: t['isDone'] == true,
          taskId: (t['id'] as num?)?.toInt(), // NEW
        ),
    ];
    items.sort((a, b) => a.minutes.compareTo(b.minutes));
    return items;
  }

  /// The next thing that is not done yet (from now on, else the earliest one).
  static CareItem? nextUp(List<CareItem> items) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final pending = items.where((i) => !i.done).toList();
    if (pending.isEmpty) return null;
    return pending.firstWhere(
          (i) => i.minutes >= nowMinutes,
      orElse: () => pending.first,
    );
  }
}