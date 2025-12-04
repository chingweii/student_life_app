import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String name;
  final String imageUrl;
  final List<String> skills;
  final String email;
  final String gender;

  Person({
    required this.name,
    required this.imageUrl,
    required this.skills,
    required this.email,
    required this.gender,
  });

  factory Person.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Person(
      // Combine first and last name
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
      // Handle potential null image
      imageUrl: data['profile picture'] ?? 'https://via.placeholder.com/150',
      // Safely convert dynamic list to List<String>
      skills: (data['skills'] as List<dynamic>? ?? [])
          .map((skill) => _toTitleCase(skill.toString()))
          .toList(),
      email: data['email'] ?? '',
      gender: data['gender'] ?? 'Unknown',
    );
  }

  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
