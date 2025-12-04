import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

class RegistrationBottomSheet extends StatefulWidget {
  final String eventTitle; // Receive the event name/ID

  const RegistrationBottomSheet({super.key, required this.eventTitle});

  @override
  State<RegistrationBottomSheet> createState() =>
      _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<RegistrationBottomSheet> {
  // 1. Create Controllers to capture text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false; // To show a loading spinner

  // 2. The Function to Save to Firebase
  Future<void> _submitRegistration() async {
    final String name = _nameController.text.trim();
    final String id = _idController.text.trim();
    final String email = _emailController.text.trim();

    if (name.isEmpty || id.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- FIREBASE LOGIC HERE ---
      // Structure: events -> [Specific Event Name] -> registrations -> [Auto ID]
      await FirebaseFirestore.instance
          .collection('events') // Root collection
          .doc(widget.eventTitle) // The specific event document
          .collection('registrations') // Subcollection for this event
          .add({
            'fullName': name,
            'studentID': id,
            'email': email,
            'registeredAt': FieldValue.serverTimestamp(), // Save time
          });

      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7, // Increased slightly to handle keyboard better
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Register for ${widget.eventTitle}', // Show event name
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 3. Connect Controllers to TextFields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Student ID*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A84A3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
