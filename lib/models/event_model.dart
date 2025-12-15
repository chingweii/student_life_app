import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String time;
  final String description;
  final String speakerInfo;
  final String fee;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.description,
    required this.speakerInfo,
    required this.fee,
    required this.date,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, [String? documentId]) {
    // 1. Safe Date Parsing (Prevents crash if date is weird)
    DateTime parsedDate = DateTime.now();
    try {
      if (data['date'] is Timestamp) {
        parsedDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        // Simple parser, fallback to now() if fails
        parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
      }
    } catch (e) {
      print("Date parse error: $e");
    }

    return Event(
      // --- THE FIX IS HERE ---
      // We use '??' to provide a backup Empty String if the data is null.
      // We also check data['venue'] because your JSON uses "venue", not "location"
      id: documentId ?? data['id'] ?? '', 
      title: data['title'] ?? 'No Title',
      location: data['venue'] ?? data['location'] ?? 'Unknown Location', 
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      speakerInfo: data['speakerInfo'] ?? '',
      fee: data['fee'] ?? '',
      date: parsedDate,
    );
  }
}