import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String name;
  final String imageUrl;
  final List<String> skills;
  final String email;

  Person({
    required this.name,
    required this.imageUrl,
    required this.skills,
    required this.email,
  });

  // Factory constructor to create a Person from a Firestore Document
  factory Person.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Person(
      // Combine first and last name
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
      // Handle potential null image
      imageUrl: data['profile picture'] ?? 'https://via.placeholder.com/150',
      // Safely convert dynamic list to List<String>
      skills: List<String>.from(data['skills'] ?? []),
      email: data['email'] ?? '',
    );
  }
}
