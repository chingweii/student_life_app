import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. IMPORT THIS

class RegistrationBottomSheet extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const RegistrationBottomSheet({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<RegistrationBottomSheet> createState() =>
      _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<RegistrationBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitRegistration() async {
    final String name = _nameController.text.trim();
    final String id = _idController.text.trim();
    final String email = _emailController.text.trim();

    // Get Current Logged in User
    final User? currentUser = FirebaseAuth.instance.currentUser; // 2. GET USER

    if (name.isEmpty || id.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Safety check: Ensure user is logged in
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to register.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId);
      final registrationRef = eventRef.collection('registrations');

      // 1. CHECK FOR DUPLICATES
      final QuerySnapshot existingCheck = await registrationRef
          .where(
            Filter.or(
              Filter('studentID', isEqualTo: id),
              Filter('email', isEqualTo: email),
            ),
          )
          .limit(1)
          .get();

      if (existingCheck.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This Student ID or Email is already registered!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. PROCEED TO REGISTER (Event Side)
      await registrationRef.add({
        'fullName': name,
        'studentID': id,
        'email': email,
        'registeredAt': FieldValue.serverTimestamp(),
        'userUid': currentUser.uid, // Store the UID for reference
      });

      // 3. NEW: SAVE TO USER PROFILE (User Side)
      // This allows the Profile Screen to find the event easily!
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('my_events') // A new sub-collection for the user
          .doc(
            widget.eventId,
          ) // Use event ID as document ID to prevent duplicates
          .set({
            'eventId': widget.eventId,
            'eventTitle': widget.eventTitle,
            'registeredAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered for ${widget.eventTitle}!')),
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

  // ... (dispose and build methods remain exactly the same as your code) ...
  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the keyboard height
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // 2. Return Padding directly (Remove FractionallySizedBox)
    return Padding(
      padding: EdgeInsets.only(
        // Add the keyboard height to the bottom padding
        bottom: bottomPadding,
        left: 16,
        right: 16,
        top: 16,
      ),
      // 3. Wrap in SingleChildScrollView so it never overflows (Yellow/Black stripes)
      child: SingleChildScrollView(
        child: Column(
          // 4. Make the column only as tall as the content (Auto-fit)
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Register for ${widget.eventTitle}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
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

            // 5. REPLACED Spacer() with a fixed SizedBox
            // Spacer() causes crashes inside SingleChildScrollView
            const SizedBox(height: 24),

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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ),
            // Add a little safety space at the bottom
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
