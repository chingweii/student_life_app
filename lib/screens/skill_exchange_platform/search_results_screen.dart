import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_life_app/models/person_model.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery; // Receive the query

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
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
        title: Text(
          "Searching: ${widget.searchQuery}",
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- The Search Bar (Visual only in this context, or functional if you reload) ---
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
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (val) {
                // Optional: Allow searching again from this screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultsScreen(searchQuery: val),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'People Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // --- The Firestore List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // QUERY LOGIC:
              // We look into 'users' collection where 'skills' array contains the search text.
              // Note: Firestore queries are case-sensitive.
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('skills', arrayContains: widget.searchQuery)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Handle Errors
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // 2. Handle Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 3. Handle Empty Data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No users found with skill "${widget.searchQuery}"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // 4. Display Data
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Convert Firestore doc to our Person object
                    Person person = Person.fromFirestore(docs[index]);
                    return _buildPersonCard(person);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for a single person card (Kept your original styling)
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
              // Handle network image vs asset image safely
              backgroundImage: NetworkImage(person.imageUrl),
              onBackgroundImageError: (_, __) {
                // Fallback if image fails
              },
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
                  // Display skills safely
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: person.skills
                        .map(
                          (skill) => Chip(
                            label: Text(
                              skill,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
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
