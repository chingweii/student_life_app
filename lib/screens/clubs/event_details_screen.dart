import 'package:flutter/material.dart';
import 'package:student_life_app/models/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 1. Use a Stack to layer widgets on top of each other
        child: Stack(
          children: [
            // --- LAYER 1: The Scrollable Content ---
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Add an invisible box here so the text doesn't
                  // start underneath the back button immediately.
                  const SizedBox(height: 60),

                  // --- Details Content ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title added here since banner is gone, to make it look complete
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        _buildSectionTitle('Description'),
                        _buildSectionContent(event.description),
                        // Note: If 'whatToExpect' is not in your Event model,
                        // you might want to remove this hardcoded section or make it dynamic later.
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
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) =>
                                    const RegistrationBottomSheet(),
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

            // --- LAYER 2: The Fixed Back Button ---
            Positioned(
              top: 0, // Pin to top
              left: 0, // Pin to left
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: const EdgeInsets.only(left: 30.0),
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
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
    return FractionallySizedBox(
      heightFactor: 0.55,
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
            const Text(
              'It only takes a minute to join!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
