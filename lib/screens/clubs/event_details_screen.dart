import 'package:flutter/material.dart';
import 'package:student_life_app/models/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Back Button ---
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(); // Navigate back to the previous screen
                },
                // Removing default padding to align with the design
                padding: const EdgeInsets.only(
                  left: 30.0,
                ), // Adds 16 pixels of space to the left
                constraints: const BoxConstraints(),
              ),

              // --- Banner Image ---
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset(
                    event.bannerUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // --- All content goes inside this Padding ---
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Description'),
                    _buildSectionContent(event.description),
                    _buildSectionTitle('What to Expect:'),
                    _buildSectionContent(
                      '• Keynote talks by experienced UI/UX professionals\n'
                      '• Hands-on design challenges and live critiques\n'
                      '• Tips on designing for accessibility, responsiveness, and engagement\n'
                      '• Networking opportunities with fellow designers and developers',
                    ),
                    _buildSectionTitle('Time'),
                    _buildSectionContent(event.time),
                    _buildSectionTitle('Venue'),
                    _buildSectionContent(event.location),
                    _buildSectionTitle('Speaker Information'),
                    _buildSectionContent(event.speakerInfo),
                    _buildSectionTitle('Fee'),
                    _buildSectionContent(event.fee),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // --- MODIFY THIS ONPRESSED CALLBACK ---
                        onPressed: () {
                          // This function shows the bottom sheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled:
                                true, // IMPORTANT: Allows sheet to resize for keyboard
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              // Gives it the rounded top corners
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) =>
                                const RegistrationBottomSheet(), // Your form widget
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A84A3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(content, style: const TextStyle(fontSize: 16, height: 1.5));
  }
}

class RegistrationBottomSheet extends StatelessWidget {
  const RegistrationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the content with FractionallySizedBox to control the height
    return FractionallySizedBox(
      heightFactor: 0.55, // Set the height to 80% of the screen height
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          // mainAxisSize is no longer needed as the height is fixed by the parent
          children: [
            // The small grey drag handle
            Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'It only takes a minute to join!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Your TextFields
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Student ID*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(), // Use a Spacer to push the button to the bottom
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A84A3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 60), // Some extra space at the bottom
          ],
        ),
      ),
    );
  }
}
