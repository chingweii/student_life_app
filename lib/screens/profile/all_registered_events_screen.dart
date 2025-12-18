import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_life_app/models/event_model.dart';
import 'package:student_life_app/screens/clubs/event_details_screen.dart';

class AllRegisteredEventsScreen extends StatelessWidget {
  const AllRegisteredEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "All Registered Events",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // 1. Listen for changes in the user's 'my_events' ID list
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('my_events')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No registered events found."));
          }

          // 2. Pass the IDs to a helper that fetches details & sorts by DATE
          return FutureBuilder<List<Event>>(
            future: _fetchAndSortEvents(snapshot.data!.docs),
            builder: (context, eventListSnapshot) {
              if (eventListSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!eventListSnapshot.hasData ||
                  eventListSnapshot.data!.isEmpty) {
                return const Center(child: Text("No upcoming events found."));
              }

              final sortedEvents = eventListSnapshot.data!;

              // 3. Display the List (Now strictly sorted by Date)
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedEvents.length,
                itemBuilder: (context, index) {
                  return _buildVerticalEventCard(context, sortedEvents[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- HELPER FUNCTION: Fetch, Combine, and Sort ---
  Future<List<Event>> _fetchAndSortEvents(
    List<QueryDocumentSnapshot> myEventDocs,
  ) async {
    // 1. Create a list of Futures to fetch every event in parallel
    var futures = myEventDocs.map((doc) async {
      var data = doc.data() as Map<String, dynamic>;
      String eventId = data['eventId'];

      var eventSnap = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (eventSnap.exists && eventSnap.data() != null) {
        return Event.fromFirestore(eventSnap.data()!, eventSnap.id);
      }
      return null;
    });

    // 2. Wait for all data to arrive
    var results = await Future.wait(futures);

    // 3. Remove any nulls (events that might have been deleted from DB)
    var events = results.whereType<Event>().toList();

    // 4. SORT BY DATE (Ascending: Nearest date at top)
    events.sort((a, b) {
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;

      // If dates are exactly the same, sort by Time string
      return a.time.compareTo(b.time);
    });

    return events;
  }

  Widget _buildVerticalEventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFEF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Date Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "${event.date.day}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    _getMonthName(event.date.month),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.time,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
