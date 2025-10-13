import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The light grey background color from the design
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        // Use SingleChildScrollView to prevent overflow when the keyboard appears
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // Navigate back to the previous screen
                    Navigator.of(context).pop();
                  },
                  // Removing default padding to align with the design
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: 30),

                // Header Text: "Login here"
                const Text(
                  'Login here',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 40),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Text Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Text Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true, // Hides the password text
                        decoration: _inputDecoration('Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // "Forgot your password?" Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Handle forgot password logic
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Color(0xFF8A84A3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Main Login Button
                SizedBox(
                  width: double.infinity, // Makes the button full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate the form before proceeding
                      if (_formKey.currentState!.validate()) {
                        // TODO: Handle login logic
                        print('Login Successful');
                      }
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

                const SizedBox(height: 20),

                // "Create new account" Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to registration screen
                    },
                    child: const Text(
                      'Create new account',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // "Or continue with" Divider
                _buildDivider(),

                const SizedBox(height: 30),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: 'assets/images/google_icon.png',
                    ), // Placeholder path
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: 'assets/images/phone_icon.png',
                    ), // Placeholder path
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: 'assets/images/apple_icon.png',
                    ), // Placeholder path
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create styled input fields, reducing code duplication
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF8A84A3), width: 2.0),
      ),
    );
  }

  // Helper method for the "Or continue with" divider
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  // Helper method for the social login buttons.
  // NOTE: You'll need to add your own icon images to your assets folder.
  Widget _buildSocialButton({required String icon}) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle social login
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        // Replace with Image.asset(icon) if you have image files.
        // For now, I'll use placeholders.
        child: Icon(
          icon.contains('google')
              ? Icons.alternate_email
              : icon.contains('apple')
              ? Icons.apple
              : Icons.phone_android,
          size: 28,
          color: Colors.black87,
        ),
      ),
    );
  }
}
