import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // search bar
              _buildSearchBar(context),
              const SizedBox(height: 32),

              // title
              const Text(
                'What motivates you today?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // category cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 6, // Horizontal space between cards
                  mainAxisSpacing: 6, // Vertical space between cards
                  childAspectRatio: 2.5, // Adjust ratio of width to height
                  children: [
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.language,
                      label: 'Languages',
                      onTap: () {},
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.futbol,
                      label: 'Sports',
                      onTap: () {},
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.solidComments,
                      label: 'Communication Skills',
                      onTap: () {},
                    ),
                    _buildCategoryCard(
                      icon: FontAwesomeIcons.personChalkboard,
                      label: 'Public Speaking',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the search bar
  // Inside SearchScreen class...

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        textInputAction:
            TextInputAction.search, // Change keyboard button to 'Search'
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            // FIX START: Format the text before sending it
            String formattedSearch = _toTitleCase(value.trim());
            // Navigate to results page with the search query
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SearchResultsScreen(searchQuery: formattedSearch),
              ),
            );
          }
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search by exact skill (e.g. Public Speaking)',
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Helper widget for a single category card
  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          // v-- MODIFY THIS PADDING --v
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 12.0,
            bottom: 12.0,
            right: 12.0,
          ),
          child: Row(
            children: [
              FaIcon(icon, size: 24, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
