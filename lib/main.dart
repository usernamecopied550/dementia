import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/caregiver_homescreen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gdabvxxzzgbdyvddovhi.supabase.co',
    anonKey: 'sb_publishable_b7pYpEwEQIrtxbPkUSJxfw_PztW8IyH',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Keeps the app phone-sized on wide screens (Edge/desktop).
      // On a real phone this changes nothing.
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFDDE3EA),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child!,
          ),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  late Future<String?> roleFuture;

  @override
  void initState() {
    super.initState();
    roleFuture = checkUserRole();
  }

  Future<String?> checkUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return profile?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load your account.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        roleFuture = checkUserRole();
                      });
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data == 'patient') {
          return const HomeScreen();
        }

        if (snapshot.data == 'caregiver') {
          return const CaregiverHomeScreen();
        }

        if (Supabase.instance.client.auth.currentUser != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No valid profile found for this account.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        return const LoginScreen();
      },
    );
  }
}