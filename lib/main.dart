import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finalassignment/screens/dashboard_screen.dart';

const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.firebaseReady,
    this.geminiApiKey = _geminiApiKey,
  });

  final bool firebaseReady;
  final String geminiApiKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingo AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B63F6),
          surface: const Color(0xFFF5F7FC),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F4FA),
      ),
      home: DashboardScreen(
        firebaseReady: firebaseReady,
        geminiApiKey: geminiApiKey,
      ),
    );
  }
}
