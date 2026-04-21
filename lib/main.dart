import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalassignment/screens/dashboard_screen.dart';
import 'package:finalassignment/screens/login_screen.dart';
import 'firebase_options.dart';

const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

Future<void> main() async {
  // Ensure Flutter engine is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    // Log the error for debugging, but still run the app to show an error UI
    debugPrint("Firebase initialization error: $e");
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
      // Check initialization BEFORE calling FirebaseAuth
      home: !firebaseReady
          ? const Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Error: Firebase failed to initialize. \n'
                    'Please run "flutterfire configure" and check your setup.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // 1. Handle loading state while checking auth status
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFFF2F4FA),
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // 2. Handle stream errors
                if (snapshot.hasError) {
                  return Scaffold(
                    backgroundColor: const Color(0xFFF2F4FA),
                    body: Center(
                      child: Text('Stream Error: ${snapshot.error}'),
                    ),
                  );
                }

                // 3. Navigate based on authentication status
                if (snapshot.hasData && snapshot.data != null) {
                  // User is logged in
                  return DashboardScreen(
                    firebaseReady: firebaseReady,
                    geminiApiKey: geminiApiKey,
                  );
                } else {
                  // User is not logged in
                  return LoginScreen(
                    firebaseReady: firebaseReady,
                    geminiApiKey: geminiApiKey,
                  );
                }
              },
            ),
    );
  }
}
