import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW: For current user
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: To check DB
import 'package:student_life_app/models/event_model.dart';
import 'package:student_life_app/screens/clubs/event_registration_bottom_sheet.dart';

// CHANGED: Now a StatefulWidget so we can check registration status on load
class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  // --- NEW: Check if user is already in the 'registrations' collection ---
  Future<void> _checkRegistrationStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('registrations')
            .where('eventId', isEqualTo: widget.event.id)
            .where('studentId', isEqualTo: user.uid)
            .limit(1) // We only need to know if 1 exists
            .get();

        if (mounted) {
          setState(() {
            _isRegistered = querySnapshot.docs.isNotEmpty;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error checking registration: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // User not logged in
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPER: Compare Date AND Time (Same as before) ---
  bool _isEventPast() {
    final now = DateTime.now();
    try {
      String startTimeString = widget.event.time
          .split(' to ')[0]
          .split('-')[0]
          .trim();
      startTimeString = startTimeString.replaceAll(' ', '').toUpperCase();
      bool isPm = startTimeString.contains('PM');
      String timeNumbers = startTimeString
          .replaceAll('AM', '')
          .replaceAll('PM', '');
      List<String> parts = timeNumbers.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      DateTime eventDateTime = DateTime(
        widget.event.date.year,
        widget.event.date.month,
        widget.event.date.day,
        hour,
        minute,
      );
      return eventDateTime.isBefore(now);
    } catch (e) {
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final eventMidnight = DateTime(
        widget.event.date.year,
        widget.event.date.month,
        widget.event.date.day,
      );
      return eventMidnight.isBefore(todayMidnight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPast = _isEventPast();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- LAYER 1: Scrollable Content ---
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.event.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        _buildSectionTitle('Description'),
                        _buildSectionContent(widget.event.description),

                        _buildSectionTitle('What to Expect:'),
                        _buildSectionContent(
                          '• Keynote talks by experienced UI/UX professionals\n'
                          '• Hands-on design challenges and live critiques\n'
                          '• Tips on designing for accessibility, responsiveness, and engagement\n'
                          '• Networking opportunities with fellow designers and developers',
                        ),

                        _buildSectionTitle('Time'),
                        _buildSectionContent(widget.event.time),

                        _buildSectionTitle('Venue'),
                        _buildSectionContent(widget.event.location),

                        _buildSectionTitle('Speaker Information'),
                        _buildSectionContent(widget.event.speakerInfo),

                        _buildSectionTitle('Fee'),
                        _buildSectionContent(widget.event.fee),

                        const SizedBox(height: 40),

                        // --- REGISTER BUTTON LOGIC (UPDATED) ---
                        // DELETE THE OLD SIZEDBOX HERE AND PASTE THIS NEW ONE:
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            // LOGIC:
                            // 1. If Loading -> Disabled (Null)
                            // 2. If Past -> Disabled (Null) - This overrides everything else.
                            // 3. If Registered -> ENABLED (Not Null), but does a different action.
                            // 4. Default -> ENABLED (Not Null), opens registration.
                            onPressed: (_isLoading || isPast)
                                ? null
                                : () {
                                    if (_isRegistered) {
                                      // If already registered, just show a message
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "You have already registered for this event!",
                                          ),
                                          backgroundColor: Colors.blue,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      // If NOT registered, open the form
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
                                            RegistrationBottomSheet(
                                              eventId:
                                                  widget.event.id.isNotEmpty
                                                  ? widget.event.id
                                                  : "unknown_id",
                                              eventTitle:
                                                  widget.event.title.isNotEmpty
                                                  ? widget.event.title
                                                  : "Event",
                                            ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              // COLOR LOGIC:
                              // Active (Purple): If Future (regardless of registered or not)
                              // Disabled (Grey): Only if Past or Loading
                              backgroundColor: const Color(0xFF8A84A3),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.white,
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
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    // TEXT LOGIC
                                    isPast
                                        ? 'Event Ended'
                                        : _isRegistered
                                        ? 'Registered' // Shows status, but button is still purple
                                        : 'Register',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),

                        // --- END OF NEW BUTTON LOGIC ---
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LAYER 2: Header ---
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
