import 'package:flutter/material.dart';
import 'package:student_life_app/screens/auth/login.dart'; // IMPORT YOUR NEW SCREEN
import 'package:student_life_app/screens/auth/registration.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/typing.png', fit: BoxFit.fitWidth),

            const SizedBox(height: 40.0),

            const Text(
              'Be Part of\nSomething Bigger',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const Spacer(),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  // Login Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 2. UPDATE THIS onPressed CALLBACK
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A84A3),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Register Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            Colors.black87, // This sets the text color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 3, // Add a subtle shadow like in the design
                        side: BorderSide(
                          color: Colors.grey[300]!,
                        ), // A light border
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ), // Expanded
                ],
              ),
            ),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
