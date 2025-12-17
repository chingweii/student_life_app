import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_life_app/models/person_model.dart';
import 'package:student_life_app/screens/messaging/messaging.dart';
import 'package:student_life_app/screens/profile/other_user_profile_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery; // e.g., "Sports" or "Cheryl"

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;

  // --- 1. DEFINE YOUR CATEGORIES HERE ---
  // This tells the app what skills belong to each category.
  // Make sure all keywords here are LOWERCASE.
  final Map<String, List<String>> _categoryDefinitions = {
    'languages': [
      'english',
      'mandarin',
      'malay',
      'japanese',
      'korean',
      'french',
      'spanish',
      'german',
    ],
    'sports': [
      'badminton',
      'basketball',
      'volleyball',
      'football',
      'soccer',
      'tennis',
      'swimming',
      'jogging',
      'gym',
    ],
    'interpersonal skills': [
      'communication',
      'teamwork',
      'leadership',
      'empathy',
      'active listening',
      'negotiation',
    ],
    'professional skills': [
      'public speaking',
      'project management',
      'python',
      'flutter',
      'data analysis',
      'marketing',
      'design',
    ],
  };

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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search by name or skill...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SearchResultsScreen(searchQuery: val.trim()),
                    ),
                  );
                }
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                final allDocs = snapshot.data!.docs;
                final String query = widget.searchQuery.toLowerCase();

                // --- 2. INTELLIGENT FILTERING LOGIC ---
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // A. PREPARE DATA
                  String firstName = (data['first_name'] ?? '')
                      .toString()
                      .toLowerCase();
                  String lastName = (data['last_name'] ?? '')
                      .toString()
                      .toLowerCase();
                  String fullName = "$firstName $lastName".trim();

                  List<dynamic> userSkills = [];
                  if (data['skills'] != null && data['skills'] is List) {
                    userSkills = data['skills'];
                  }

                  // B. CHECK IF THIS IS A CATEGORY SEARCH (e.g., "Sports")
                  if (_categoryDefinitions.containsKey(query)) {
                    // Get the list of related skills (e.g., basketball, badminton)
                    List<String> relatedSkills = _categoryDefinitions[query]!;

                    // Check if user has ANY of these related skills
                    bool hasRelatedSkill = userSkills.any((skill) {
                      return relatedSkills.contains(
                        skill.toString().toLowerCase(),
                      );
                    });

                    if (hasRelatedSkill) return true;
                  }

                  // C. STANDARD SEARCH (Name or Specific Skill)
                  bool isNameMatch =
                      firstName.contains(query) ||
                      lastName.contains(query) ||
                      fullName.contains(query);

                  bool isDirectSkillMatch = userSkills.any((skill) {
                    return skill.toString().toLowerCase() == query;
                  });

                  return isNameMatch || isDirectSkillMatch;
                }).toList();
                // --------------------------------------

                if (filteredDocs.isEmpty) {
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
                          'No results for "${widget.searchQuery}"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    Person person = Person.fromFirestore(filteredDocs[index]);
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

  Widget _buildPersonCard(Person person) {
    return GestureDetector(
      onTap: () {
        // Navigate to the public profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfileScreen(userID: person.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(person.imageUrl),
                onBackgroundImageError: (_, __) {},
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

              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.person_add_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // Implement friend request functionality here
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagingScreen(
                            recipientName: person.name,
                            recipientImage: person.imageUrl,
                            recipientUid: person.id,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
