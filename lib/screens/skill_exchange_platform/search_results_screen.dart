import 'package:flutter/material.dart';

class Person {
  final String name;
  final String imageUrl;
  final List<String> skills;

  Person({required this.name, required this.imageUrl, required this.skills});
}

final List<Person> mockPeople = [
  Person(
    name: 'Cheryl Tan Mei Ling',
    imageUrl: 'assets/images/user1.png', // Make sure you have these assets
    skills: ['Public Speaking', 'Leadership'],
  ),
  Person(
    name: 'Lim Jia Xin',
    imageUrl: 'assets/images/user2.png',
    skills: ['Public Speaking', 'Japanese'],
  ),
  Person(
    name: 'Alex Goh Wei Bin',
    imageUrl: 'assets/images/user3.png',
    skills: ['Public Speaking', 'Football'],
  ),
  Person(
    name: 'Cassandra Khoo',
    imageUrl: 'assets/images/user4.png',
    skills: ['Public Speaking', 'Volleyball'],
  ),
  Person(
    name: 'Mandy Soo Hui Qi',
    imageUrl: 'assets/images/user5.png',
    skills: ['Public Speaking', 'Mandarin'],
  ),
];

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Public Speaking');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- The "Public Speaking" Chip ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, // No visible border line
                ),
                contentPadding: EdgeInsets.zero, // Adjust padding if needed
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- The "People Found" Title ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'People Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // --- The List of People ---
          Expanded(
            child: ListView.builder(
              itemCount: mockPeople.length,
              itemBuilder: (context, index) {
                final person = mockPeople[index];
                return _buildPersonCard(person);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for a single person card
  Widget _buildPersonCard(Person person) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(person.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Skills:\n${person.skills.join('\n')}', // Display skills on new lines
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Icons on the right
            IconButton(
              icon: Icon(Icons.person_add_outlined, color: Colors.grey[600]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
