import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:student_life_app/screens/welcome_screen.dart';
  
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
      debugShowCheckedModeBanner: false,
      title: 'Student Life App',
      theme: ThemeData(
        // This sets the background color for all Scaffolds in your app
        scaffoldBackgroundColor: Colors.white,

        // This makes the BottomNavigationBar theme consistent too
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        // This makes your AppBar theme consistent
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,

          // This sets the default text style for all AppBars
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),

          // This sets the color for icons (like back buttons)
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}
