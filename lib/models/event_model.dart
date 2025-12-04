import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String location;
  final String time;
  // bannerUrl removed
  final String description;
  final String speakerInfo;
  final String fee;
  final DateTime date;

  Event({
    required this.title,
    required this.location,
    required this.time,
    // bannerUrl removed
    required this.description,
    required this.speakerInfo,
    required this.fee,
    required this.date,
  });

  // Factory to convert Firestore JSON into an Event object
  factory Event.fromFirestore(Map<String, dynamic> data) {
    // Handle date: It might be a Timestamp (from Firestore) or a String
    DateTime parsedDate;

    try {
      if (data['date'] is Timestamp) {
        parsedDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        // --- SAFE PARSING START ---
        // Try to parse standard format
        parsedDate = DateTime.parse(data['date']);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      // If parsing fails, don't crash! Just use current date.
      print("⚠️ Date Error for event '${data['title']}': $e");
      parsedDate = DateTime.now();
    }
    // --- SAFE PARSING END ---

    return Event(
      title: data['title'] ?? '',
      // Checks 'venue' first, then 'location'
      location: data['venue'] ?? data['location'] ?? '',
      time: data['time'] ?? '',
      // bannerUrl removed
      description: data['description'] ?? '',
      speakerInfo: data['speakerInfo'] ?? '',
      fee: data['fee'] ?? '',
      date: parsedDate,
    );
  }
}
