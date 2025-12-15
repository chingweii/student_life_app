import 'package:flutter/material.dart';
import 'package:student_life_app/models/event_model.dart';
import 'package:student_life_app/screens/clubs/event_registration_bottom_sheet.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- LAYER 1: The Scrollable Content ---
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Spacing to ensure text starts below the header
                  const SizedBox(height: 70),

                  // --- Details Content ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- EVENT TITLE ---
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        // --- NEW: EVENT ID (Small & Semi-Transparent) ---
                        const SizedBox(height: 4), // Tiny gap
                        Text(
                          'ID: ${event.id}',
                          style: const TextStyle(
                            fontSize: 13, // Small size
                            color: Colors.black45, // Semi-transparent/Greyish
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        _buildSectionTitle('Description'),
                        _buildSectionContent(event.description),

                        _buildSectionTitle('What to Expect:'),
                        // Note: You might want to map this from event.whatToExpect later
                        // instead of hardcoding it.
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

                        // --- REGISTER BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Safety Check: Print to console to debug
                              print("Registering for Event ID: ${event.id}");

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => RegistrationBottomSheet(
                                  // SAFETY FIX: Add ?? "" to ensure it is never null
                                  eventId: event.id.isNotEmpty
                                      ? event.id
                                      : "unknown_id",
                                  eventTitle: event.title.isNotEmpty
                                      ? event.title
                                      : "Event",
                                ),
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

            // --- LAYER 2: The Full-Width White Header (No Line) ---
            Positioned(
              top: 0,
              left: 5,
              right: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(color: Colors.white),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
