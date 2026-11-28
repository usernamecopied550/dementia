import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/colors.dart';
import '../services/caregiver_task_service.dart';
import '../services/pairing_service.dart';
import '../widgets/caregiver_connection_banner.dart';
import '../widgets/caregiver_widgets.dart';
import 'caregiver_care_plan_screen.dart';
import 'caregiver_contacts_screen.dart';
import 'welcome_screen.dart';
import 'patient_info_screen.dart';

/// Caregiver side: bottom navigation with 4 tabs.
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  int _index = 0;

  final _pairing = PairingService();
  String? _patientName;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final name = await _pairing.getLinkedPersonName('caregiver');
      if (!mounted) return;
      setState(() {
        _patientName = name;
        _checking = false;
        if (name == null) _index = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _patientName = null; _checking = false; _index = 0; });
    }
  }

  void _goTo(int index) {
    if (index != 0 && _patientName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link a patient first.')),
      );
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CaregiverDashboard(onNavigate: _goTo, patientName: _patientName,
          checking: _checking, onConnectionChanged: _checkConnection),
      const CaregiverCarePlanScreen(),
      const CaregiverContactsScreen(),
      PatientInfoScreen(onOpenContacts: () => _goTo(2)),
    ];

    return Scaffold(
      backgroundColor: AppColors.grey,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: pages[_index],
        ),
      ),
      // Bottom bar: same max width as the page content, centred
      bottomNavigationBar: Align(
        heightFactor: 1,
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(26)),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _goTo,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.lightBlue,
              elevation: 0,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: AppColors.muted),
                  selectedIcon:
                  Icon(Icons.home_rounded, color: AppColors.deepBlue),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(_patientName == null ? Icons.lock_outline : Icons.event_note_outlined, color: AppColors.muted),
                  selectedIcon:
                  Icon(Icons.event_note, color: AppColors.deepBlue),
                  label: 'Care plan',
                ),
                NavigationDestination(
                  icon: Icon(_patientName == null ? Icons.lock_outline : Icons.people_outline, color: AppColors.muted),
                  selectedIcon: Icon(Icons.people, color: AppColors.deepBlue),
                  label: 'Contacts',
                ),
                NavigationDestination(
                  icon: Icon(_patientName == null ? Icons.lock_outline : Icons.person_outline, color: AppColors.muted),
                  selectedIcon: Icon(Icons.person, color: AppColors.deepBlue),
                  label: 'Patient',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home tab.
class CaregiverDashboard extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  final String? patientName;
  final bool checking;
  final VoidCallback onConnectionChanged;

  const CaregiverDashboard({super.key, required this.onNavigate,
    required this.patientName, required this.checking,
    required this.onConnectionChanged});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadToday();
  }

  Future<List<Map<String, dynamic>>> _loadToday() async {
    if (widget.patientName == null) return [];
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tasks = await CaregiverTaskService.loadTasksWithCompletion();
    return tasks.where((t) => t['is_recurring'] == true ||
        t['scheduled_date']?.toString() == today).toList();
  }

  @override
  void didUpdateWidget(covariant CaregiverDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientName != widget.patientName) {
      _tasksFuture = _loadToday();
    }
  }

  Future<void> _refresh() async {
    setState(() => _tasksFuture = _loadToday());
    await _tasksFuture.catchError((_) => <Map<String, dynamic>>[]);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final tasks = snapshot.data ?? [];
          final done = tasks.where((t) => t['isDone'] == true).length;
          final total = tasks.length;
          final now = DateTime.now();
          final clock = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          final pending = tasks.where((t) => t['isDone'] != true).toList();
          pending.sort((a,b) => a['scheduled_time'].toString().compareTo(b['scheduled_time'].toString()));
          final upcoming = pending.where((t) => t['scheduled_time'].toString().compareTo(clock) >= 0).toList();
          final next = upcoming.isEmpty ? null : upcoming.first;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                PageHeader(
                  subtitle: _greeting,
                  title: 'Caregiver',
                  trailing: CircleIconButton(
                    icon: Icons.logout_rounded,
                    tooltip: 'Log out',
                    onPressed: _logout,
                  ),
                ),
                const SizedBox(height: 18),
                CaregiverConnectionBanner(onConnectionChanged: widget.onConnectionChanged),
                if (widget.patientName == null) ...[
                  const SizedBox(height: 16),
                  if (!widget.checking) TextButton(onPressed: widget.onConnectionChanged,
                      child: const Text('Refresh connection')),
                  const Text('Link a patient to access the care plan, contacts and patient information.'),
                ] else if (snapshot.hasError) ...[
                  const SizedBox(height: 16),
                  TextButton(onPressed: _refresh, child: const Text('Could not load tasks. Retry')),
                ] else ...[
                  const SizedBox(height: 18),
                  _PatientHeroCard(
                    patientName: widget.patientName!,
                    done: done,
                    total: total,
                    loading: loading,
                    onTap: () => widget.onNavigate(3),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Today at a glance',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate(1),
                        child: const Text('See plan',
                            style: TextStyle(
                                color: AppColors.deepBlue,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: loading ? '–' : '${total - done}',
                          label: 'Tasks remaining',
                          icon: Icons.pending_actions,
                          color: AppColors.blue,
                          badgeColor: AppColors.lightBlue,
                          iconColor: AppColors.deepBlue,
                          onTap: () => widget.onNavigate(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: loading ? '–' : '$done/${tasks.length}',
                          label: 'Tasks completed',
                          icon: Icons.checklist_rounded,
                          color: AppColors.lightGreen,
                          badgeColor: AppColors.midGreen,
                          iconColor: AppColors.green,
                          onTap: () => widget.onNavigate(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (next != null) ...[
                    _NextUpCard(item: next),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _QuickTile(
                          label: 'Contacts',
                          icon: Icons.people_outline,
                          badgeColor: AppColors.lightGreen,
                          iconColor: AppColors.green,
                          onTap: () => widget.onNavigate(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickTile(
                          label: 'Patient info',
                          icon: Icons.person_outline,
                          badgeColor: AppColors.lightBlue,
                          iconColor: AppColors.deepBlue,
                          onTap: () => widget.onNavigate(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PatientHeroCard extends StatelessWidget {
  final String patientName;
  final int done;
  final int total;
  final bool loading;
  final VoidCallback onTap;

  const _PatientHeroCard({
    required this.patientName,
    required this.done,
    required this.total,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Material(
      color: AppColors.deepBlue,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              right: -40,
              top: -40,
              child: _circle(160, const Color(0x598FAAC3)),
            ),
            Positioned(
              right: 30,
              top: 60,
              child: _circle(70, const Color(0x408FAAC3)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blue, width: 3),
                        ),
                        child: Text(patientName.trim().isEmpty ? '?' : patientName.trim()[0].toUpperCase(),
                            style: TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Caring for',
                              style: TextStyle(
                                  color: AppColors.lightBlue, fontSize: 13)),
                          SizedBox(height: 2),
                          Text(patientName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Today's progress",
                            style: TextStyle(
                                color: AppColors.lightBlue, fontSize: 13)),
                      ),
                      Text(
                        loading ? 'Loading…' : '$done of $total done',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0x33FFFFFF),
                      color: AppColors.progressGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color badgeColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.badgeColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: icon, background: badgeColor, color: iconColor),
              const SizedBox(height: 12),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _NextUpCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          IconBadge(
            icon: Icons.schedule_rounded,
            size: 44,
            background: AppColors.lightGreen,
            color: AppColors.green,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT UP · ${item['scheduled_time'].toString().split(':').take(2).join(':')}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                      letterSpacing: 0.6),
                ),
                const SizedBox(height: 2),
                Text(
                  item['title'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Task',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greenText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color badgeColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickTile({
    required this.label,
    required this.icon,
    required this.badgeColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              IconBadge(
                  icon: icon, size: 36, background: badgeColor, color: iconColor),
              const SizedBox(width: 12),
              Flexible(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
