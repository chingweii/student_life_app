import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the muted purple color from your button
    final Color primaryColor = Color(0xFF8A84A3);
    // This is the light grey border color from your text fields
    final Color borderColor = Colors.grey.shade300;

    // --- This is the style for the Pinput boxes ---
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Match your text field radius
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // The standard back icon
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            const SizedBox(height: 16),

            // 1. Title
            const Text(
              'Verify Account',
              style: TextStyle(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 2. Instruction Text
            Text(
              'Enter the 6-digit code sent to your email.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            const SizedBox(height: 32),

            // 3. OTP Input Boxes
            Center(
              child: Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                // Style for the box when it's being typed in
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(
                      color: primaryColor,
                    ), // Highlight with purple
                  ),
                ),
                // Style for the box when it's filled
                submittedPinTheme: defaultPinTheme,
                onCompleted: (pin) {
                  // This is where you'd verify the code
                  print('Entered PIN: $pin');
                },
              ),
            ),

            const SizedBox(height: 32),

            // 4. Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Use the same purple
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Add verification logic here
                },
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Resend Code Link
            Center(
              child: TextButton(
                onPressed: () {
                  // Add "resend code" logic here
                },
                child: Text(
                  "Didn't receive code? Resend",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
