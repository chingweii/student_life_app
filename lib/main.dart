import 'package:flutter/material.dart';
import 'package:student_life_app/screens/home_screen.dart';
import 'package:student_life_app/screens/welcome_screen.dart';
import 'package:student_life_app/screens/skill_exchange_platform/search_results_screen.dart';
import 'package:student_life_app/models/navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Life App',
      debugShowCheckedModeBanner: false, // This removes the debug banner
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomSheetTheme: const BottomSheetThemeData(
          surfaceTintColor: Colors.transparent,
          backgroundColor:
              Colors.white, // You can set the default color here too
        ),
      ),

      // Define the routes for your application
      initialRoute: '/', // The route that the app starts on.
      routes: {
        // When navigating to the "/" route, build the WelcomeScreen widget.
        '/': (context) =>
            NavigationScreen(), // Before WelcomeScreen() had a const before
        // When navigating to the "/home" route, build the HomeScreen widget.
        '/home': (context) => const NavigationScreen(),
      },
    );
  }
}
