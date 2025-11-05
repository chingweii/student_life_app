import 'package:flutter/material.dart';
import 'package:student_life_app/screens/profile/settings_screen.dart';

// --- Data Models ---
class UserProfile {
  final String name;
  final String imageUrl;
  final String degree;
  final String location;

  UserProfile({
    required this.name,
    required this.imageUrl,
    required this.degree,
    required this.location,
  });
}

class Skill {
  final String title;
  final String subtitle;
  final String description;

  Skill({
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

// --- Mock Data ---
final userProfile = UserProfile(
  name: 'Chong Kai Xin',
  imageUrl: 'assets/images/user_avatar.png', // Make sure you have this asset
  degree: 'Bachelor of Science in Computer Science, Year 3',
  location: 'Selangor, Malaysia',
);

final List<Skill> mockSkills = [
  Skill(
    title: 'Python Programming',
    subtitle: 'Verification',
    description:
        'Python Institute PCAP (Certified Associate in Python Programming)',
  ),
  Skill(
    title: 'Japanese',
    subtitle: 'Verification',
    description: 'Japanese-Language Proficiency Test N3',
  ),
  Skill(
    title: 'Public Speaking',
    subtitle: 'Experience',
    description: 'Emcee for Events of Sunway Tech Club',
  ),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(context),
                  const SizedBox(height: 40),
                  _buildSkillsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the top profile section
  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 243, 239, 239),
          radius: 70,
          backgroundImage: AssetImage(userProfile.imageUrl),
        ),

        const SizedBox(width: 20), // more space between avatar and text

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                userProfile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 18,
                    color: Color.fromARGB(255, 68, 68, 68),
                  ), // Smaller icon

                  const SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      userProfile.degree,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 68, 68, 68),
                        fontSize: 13,
                      ), // Smaller font size
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4), // Reduced space

              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color.fromARGB(255, 68, 68, 68),
                  ), // Smaller icon

                  const SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      userProfile.location,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 68, 68, 68),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18), // Adjusted spacing before buttons

              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.settings, size: 18),
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for the "My Skills" section
  Widget _buildSkillsSection() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'My Skills',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        // Create a list of skill cards from the mock data
        ...mockSkills.map((skill) => _buildSkillCard(skill)).toList(),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Skill'),
        ),
      ],
    );
  }

  // skill card
  Widget _buildSkillCard(Skill skill) {
    return Card(
      color: const Color.fromARGB(255, 243, 239, 239),
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: Color.fromARGB(255, 68, 68, 68).withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    skill.subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(skill.description),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color.fromARGB(255, 68, 68, 68),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
