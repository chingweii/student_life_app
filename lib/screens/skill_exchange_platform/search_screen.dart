import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'search_results_screen.dart';
import 'package:student_life_app/models/person_model.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'What motivates you today?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 3.0,
                  children: [
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.language,
                      label: 'Languages',
                      onTap: () => _navigateToSearch(context, 'Languages'),
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.futbol,
                      label: 'Sports',
                      onTap: () => _navigateToSearch(context, 'Sports'),
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.solidComments,
                      label: 'Interpersonal Skills',
                      onTap: () =>
                          _navigateToSearch(context, 'Interpersonal Skills'),
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.personChalkboard,
                      label: 'Professional Skills',
                      onTap: () =>
                          _navigateToSearch(context, 'Professional Skills'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Peer Suggestions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connect with people randomly selected for you',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) return const Text("No peers found.");

                    List<QueryDocumentSnapshot> shuffledDocs = List.from(docs);
                    shuffledDocs.shuffle(Random());
                    List<QueryDocumentSnapshot> randomSelection = shuffledDocs
                        .take(10)
                        .toList();

                    return Column(
                      children: randomSelection.map((doc) {
                        Person person = Person.fromFirestore(doc);
                        return _buildPeerSuggestionCard(context, person);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // 1. NEW HELPER FUNCTION TO HANDLE IMAGE LOGIC
  ImageProvider _getProfileImage(String? imageUrl) {
    // A. If empty or null, use default local asset
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/images/user_avatar.png');
    }

    // B. If it starts with 'http', it's a Real User (Firebase Storage)
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }

    // C. Otherwise, it's a Mock User (Local Asset path)
    return AssetImage(imageUrl);
  }

  void _navigateToSearch(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(searchQuery: query),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _navigateToSearch(context, value.trim());
          }
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search by skill or name',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15.0,
            top: 12.0,
            bottom: 12.0,
            right: 8.0,
          ),
          child: Row(
            children: [
              FaIcon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeerSuggestionCard(BuildContext context, Person person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            // 2. USE THE NEW HELPER FUNCTION HERE
            backgroundImage: _getProfileImage(person.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        person.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      person.gender.toLowerCase() == 'male'
                          ? Icons.male
                          : person.gender.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.transgender,
                      size: 16,
                      color: person.gender.toLowerCase() == 'male'
                          ? Colors.blue
                          : person.gender.toLowerCase() == 'female'
                          ? Colors.pink
                          : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  person.skills.take(2).join(", "),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onPressed: () {
              // Your navigation logic
            },
          ),
        ],
      ),
    );
  }
}
