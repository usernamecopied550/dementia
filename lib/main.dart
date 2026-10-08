import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/caregiver_homescreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Supabase.instance.client.auth.currentSession != null
          ? const HomeScreen()
          : const LoginScreen(), // 👈 PATIENT SCREEN NOW
    );
  }
}