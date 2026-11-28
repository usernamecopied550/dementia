import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/colors.dart';
import '../widgets/caregiver_widgets.dart';
import 'family_screen.dart';
import 'login_screen.dart';
import 'tasks_screen.dart';

/// Patient home: greeting, next thing to do, 2 big buttons, help button.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = Supabase.instance.client;

  static const _red = Color(0xFFD32F2F);

  Map<String, dynamic>? _next;
  int _total = 0;
  int _done = 0;
  bool _loading = true;

  // Emergency contact (from the contacts table)
  String? _emergencyName;
  String? _emergencyPhone;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _dateText {
    final d = DateTime.now();
    return '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';
  }

  String _time(dynamic t) {
    final s = (t ?? '').toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  Future<void> _load() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // Tasks
    try {
      final tasks = List<Map<String, dynamic>>.from(await _db
          .from('tasks')
          .select()
          .eq('patient_id', uid)
          .or('is_recurring.eq.true,scheduled_date.eq.$_today')
          .order('scheduled_time', ascending: true));

      final doneRows = await _db
          .from('task_completions')
          .select('task_id')
          .eq('patient_id', uid)
          .eq('completed_date', _today);

      final doneIds =
      doneRows.map<int>((r) => (r['task_id'] as num).toInt()).toSet();

      final pending = tasks
          .where((t) => !doneIds.contains((t['id'] as num).toInt()))
          .toList();

      _total = tasks.length;
      _done = tasks.length - pending.length;
      _next = pending.isEmpty ? null : pending.first;
    } catch (_) {
      _next = null;
    }

    // Emergency contact (first one with a phone number)
    try {
      final rows = await _db
          .from('contacts')
          .select('full_name, phone')
          .eq('patient_id', uid)
          .eq('is_emergency', true)
          .order('created_at');

      final withPhone = rows.where(
              (r) => (r['phone'] ?? '').toString().trim().isNotEmpty);

      if (withPhone.isNotEmpty) {
        final c = withPhone.first;
        _emergencyName = (c['full_name'] ?? '').toString();
        _emergencyPhone = c['phone'].toString();
      } else {
        _emergencyName = null;
        _emergencyPhone = null;
      }
    } catch (_) {
      _emergencyName = null;
      _emergencyPhone = null;
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markDone() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null || _next == null) return;
    try {
      await _db.from('task_completions').insert({
        'task_id': (_next!['id'] as num).toInt(),
        'patient_id': uid,
        'completed_date': _today,
      });
    } catch (_) {
      // The save often works even if the reply fails, so just reload
    }
    await _load();
  }

  Future<void> _askForHelp() async {
    if (_emergencyPhone == null) return;
    final firstName = (_emergencyName ?? '').trim().split(' ').first;

    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_rounded, color: _red, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                'Call $firstName now?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 68,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                  ),
                  icon: const Icon(Icons.call_rounded, size: 30),
                  label: const Text('Yes, call',
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.softBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('No',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (yes == true && mounted) {
      await callNumber(context, _emergencyPhone!);
    }
  }

  Future<void> _logout() async {
    try {
      await _db.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CircleIconButton(
                  icon: Icons.logout_rounded,
                  tooltip: 'Log out',
                  onPressed: _logout,
                ),
              ),
              const SizedBox(height: 8),
              _hero(),
              const SizedBox(height: 20),
              _nextCard(),
              const SizedBox(height: 20),
              _BigButton(
                imagePath: 'assets/images/calendar.png',
                label: 'My tasks',
                iconBg: AppColors.lightGreen,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasksScreen()),
                  );
                  _load(); // refresh after ticking tasks
                },
              ),
              const SizedBox(height: 14),
              _BigButton(
                imagePath: 'assets/images/family.png',
                label: 'My family',
                iconBg: AppColors.lightBlue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilyScreen()),
                ),
              ),
              // Help button is now third, under the 2 big buttons
              if (_emergencyPhone != null) ...[
                const SizedBox(height: 14),
                _helpButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpButton() {
    final firstName = (_emergencyName ?? '').trim().split(' ').first;
    return Material(
      color: _red,
      borderRadius: BorderRadius.circular(26),
      elevation: 3,
      shadowColor: _red.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: _askForHelp,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.call_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I need help',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Call $firstName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _dateText,
            style: const TextStyle(fontSize: 19, color: Colors.white70),
          ),
          if (_total > 0) ...[
            const SizedBox(height: 20),
            Text(
              '$_done of $_total done today',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _done / _total,
                minHeight: 12,
                backgroundColor: Colors.white24,
                color: AppColors.progressGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _nextCard() {
    Widget child;

    if (_loading) {
      child = const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_next == null) {
      child = Row(
        children: [
          const IconBadge(
            icon: Icons.celebration_rounded,
            size: 64,
            background: AppColors.lightGreen,
            color: AppColors.green,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _total == 0 ? 'Nothing planned today' : 'All done for today!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      );
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (_next!['title'] ?? '').toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.deepBlue, size: 24),
              const SizedBox(width: 6),
              Text(
                _time(_next!['scheduled_time']),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton.icon(
              onPressed: _markDone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                foregroundColor: AppColors.greenText,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.check_rounded, size: 30),
              label: const Text(
                'I did it',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: child,
    );
  }
}

/// Big white button with a sticker in a coloured square.
class _BigButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color iconBg;
  final VoidCallback onTap;

  const _BigButton({
    required this.imagePath,
    required this.label,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 36, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}