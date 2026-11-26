import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../screens/medication_screen.dart';
import '../screens/tasks_screen.dart';
import 'family_screen.dart';
import '../patient.dart';
import '../patient_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../services/task_service.dart';
import 'dart:async';

/// 🔴 EMERGENCY SCREEN
class PatientEmergencyScreen extends StatefulWidget {
  const PatientEmergencyScreen({super.key});

  @override
  State<PatientEmergencyScreen> createState() =>
      _PatientEmergencyScreenState();
}

class _PatientEmergencyScreenState
    extends State<PatientEmergencyScreen> {
  bool alertSent = false;

  void sendAlert() {
    setState(() {
      alertSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ✅🔥 THIS IS THE FIX (BACK ARROW)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "I Need Help",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: sendAlert,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (alertSent)
                const Text(
                  "Help request sent!",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🏠 PATIENT HOME SCREEN


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TaskService taskService = TaskService();

  late Future<List<Map<String, dynamic>>> tasksFuture;

  Timer? refreshTimer;
  final Set<String> shownReminders = {};

  bool isReminderShowing = false;

  @override
  void initState() {
    super.initState();

    tasksFuture = taskService.loadTasksWithCompletion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkActivityReminders();
    });

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
          (timer) {
        refreshTasks();
      },
    );
  }

  void refreshTasks() {
    if (!mounted) return;

    setState(() {
      tasksFuture = taskService.loadTasksWithCompletion();
    });
    checkActivityReminders();
  }
  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> checkActivityReminders() async {
    if (!mounted || isReminderShowing) return;

    try {
      final tasks = await tasksFuture;

      if (!mounted || isReminderShowing) return;

      // Only show reminders when the dashboard is active.
      if (ModalRoute.of(context)?.isCurrent != true) return;

      final now = DateTime.now();

      final todayString =
          '${now.year}-${now.month}-${now.day}';

      for (final task in tasks) {

        // Ignore completed tasks.
        if (task['isDone'] == true) continue;

        final time = task['scheduled_time']
            .toString()
            .split(':');

        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(time[0]),
          int.parse(time[1]),
        );

        final difference = now.difference(scheduledTime);

        final reminderKey = '${task['id']}-$todayString';

        // Show reminders for recently due activities.
        if (!difference.isNegative &&
            difference.inMinutes < 5 &&
            !shownReminders.contains(reminderKey)) {

          shownReminders.add(reminderKey);

          await showActivityReminder(task);

          break;
        }
      }
    } catch (error) {
      debugPrint('Could not check reminders: $error');
    }
  }
  Future<void> showActivityReminder(
      Map<String, dynamic> task,
      ) async {
    if (!mounted || isReminderShowing) return;

    isReminderShowing = true;

    try {
      final viewTasks = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 50,
                  color: Color(0xFF527CAA),
                ),
                SizedBox(height: 15),
                Text(
                  'Activity Reminder',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              "It's time for your activity:\n\n${task['title']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text("View Today's Tasks"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );

      if (viewTasks == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TasksScreen(),
          ),
        );

        refreshTasks();
      }
    } finally {
      isReminderShowing = false;
    }
  }

  Widget buildActivityBanners() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Could not load activities.',
          );
        }

        final tasks = snapshot.data ?? [];
        final now = DateTime.now();

        final upcomingTasks = <Map<String, dynamic>>[];
        final overdueTasks = <Map<String, dynamic>>[];

        for (final task in tasks) {
          if (task['isDone'] == true) continue;

          final time = task['scheduled_time'].toString().split(':');

          final scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(time[0]),
            int.parse(time[1]),
          );

          if (scheduledTime.isBefore(now)) {
            overdueTasks.add(task);
          } else {
            upcomingTasks.add(task);
          }
        }

        final nextTask =
        upcomingTasks.isNotEmpty ? upcomingTasks.first : null;

        String activityTitle;
        String activityTime = '';

        if (nextTask != null) {
          activityTitle = nextTask['title'].toString();
          activityTime = nextTask['scheduled_time']
              .toString()
              .substring(0, 5);
        } else if (tasks.isEmpty) {
          activityTitle = 'No activities scheduled today';
        } else if (overdueTasks.isNotEmpty) {
          activityTitle = 'No more upcoming activities today';
        } else {
          activityTitle = 'All done for today!';
        }

        return Column(
          children: [
            // NEXT ACTIVITY BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR NEXT ACTIVITY',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activityTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (activityTime.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      activityTime,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            ),

            // OVERDUE ACTIVITIES BANNER
            if (overdueTasks.isNotEmpty) ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overdueTasks.length == 1
                          ? '1 overdue activity'
                          : '${overdueTasks.length} overdue activities',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Check your Today's Tasks list.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

// Keep the existing logout functionality
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not log out. Please try again.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Good Morning!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Here are your activities for today.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  buildActivityBanners(),
                  const SizedBox(height: 30),

// TODAY'S TASKS
                  CustomButton(
                    text: "Today's Tasks",
                    imagePath: 'assets/images/calendar.png',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasksScreen(),
                        ),
                      );

                      refreshTasks();
                    },
                  ),

                  const SizedBox(height: 15),

// EMERGENCY CONTACTS
                  CustomButton(
                    text: "Emergency Contacts",
                    imagePath: 'assets/images/alert.png',
                    onPressed: () {
// We will create this screen next.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Emergency Contacts coming soon!",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

// FAMILY (OPTIONAL FEATURE)
                  CustomButton(
                    text: "My Family",
                    imagePath: 'assets/images/family.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const FamilyScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
