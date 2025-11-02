import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:student_life_app/models/navigation.dart';
import 'package:student_life_app/screens/welcome_screen.dart';
import 'package:student_life_app/screens/skill_exchange_platform/search_results_screen.dart';

void main() async {
  // Make sure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // This one line initializes Firebase for ALL platforms
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // This runs your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Life App',
      // Make sure this points to your real home screen
      home: NavigationScreen(),
    );
  }
}
