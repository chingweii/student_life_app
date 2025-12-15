import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_life_app/screens/profile/settings_screen.dart';
import 'package:student_life_app/screens/profile/add_skill_bottom_sheet.dart';
import 'package:student_life_app/screens/profile/edit_profile_screen.dart';

enum Gender { male, female, other }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view profile")),
      );
    }

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
                  _buildProfileStream(),
                  const SizedBox(height: 40),
                  _buildSkillsStream(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStream() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("Profile not found.");
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        String firstName = data['first_name'] ?? '';
        String lastName = data['last_name'] ?? '';
        String fullName = '$firstName $lastName'.trim();
        String degree = data['degree'] ?? 'Add your degree';
        String location = data['location'] ?? 'Add location';

        // --- CHANGE 1: Extract the profile image URL from database ---
        String? profilePicUrl = data['profile_pic_url'];

        String genderString = data['gender'] ?? 'other';
        Gender genderEnum;
        if (genderString.toLowerCase() == 'male') {
          genderEnum = Gender.male;
        } else if (genderString.toLowerCase() == 'female') {
          genderEnum = Gender.female;
        } else {
          genderEnum = Gender.other;
        }

        return _buildProfileHeader(
          context,
          fullName,
          degree,
          location,
          genderEnum,
          profilePicUrl, // --- CHANGE 2: Pass the URL to the widget ---
        );
      },
    );
  }

  // --- UI Helpers ---

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String degree,
    String location,
    Gender gender,
    String? imageUrl, // --- CHANGE 3a: Accept the URL as a parameter ---
  ) {
    // --- CHANGE 3b: Determine which image provider to use ---
    ImageProvider backgroundImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      backgroundImage = NetworkImage(imageUrl); // Use Firebase URL
    } else {
      backgroundImage = const AssetImage(
        'assets/images/user_avatar.png',
      ); // Use Default
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 243, 239, 239),
          radius: 70,
          backgroundImage: backgroundImage, // Apply the image here
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      name.isEmpty ? "User" : name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  _buildGenderIcon(gender),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 18,
                    color: Color.fromARGB(255, 68, 68, 68),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      degree,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 68, 68, 68),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color.fromARGB(255, 68, 68, 68),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 68, 68, 68),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
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

  // ... (Keep your _buildSkillsStream, _buildSkillCard, _buildGenderIcon, and _showAddSkillDialog exactly the same as before) ...

  // (I omitted them here to save space, but DO NOT delete them from your file)
  Widget _buildSkillsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('skills')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var docs = snapshot.data?.docs ?? [];

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

            if (docs.isEmpty)
              const Text(
                "No skills added yet.",
                style: TextStyle(color: Colors.grey),
              ),

            // Map the Firestore documents to Widgets
            ...docs.map((doc) {
              var skillData = doc.data() as Map<String, dynamic>;
              return _buildSkillCard(
                doc.id, // Pass ID for deletion
                skillData['title'] ?? 'No Title',
                skillData['subtitle'] ?? '',
                skillData['description'] ?? '',
              );
            }).toList(),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                _showAddSkillDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Skill'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillCard(
    String docId, // We need this ID to know which one to delete
    String title,
    String subtitle,
    String description,
  ) {
    return Card(
      color: const Color.fromARGB(255, 243, 239, 239),
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
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
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle, // Displaying Category here
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description), // Displaying Description here
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () async {
                // 1. Delete from Sub-collection (Detailed data)
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('skills')
                    .doc(docId)
                    .delete();

                // 2. NEW: Remove from Main Document Array (Summary data)
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .update({
                      'skills': FieldValue.arrayRemove([title]),
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderIcon(Gender gender) {
    IconData iconData;
    Color iconColor;

    switch (gender) {
      case Gender.male:
        iconData = Icons.male;
        iconColor = Colors.blue;
        break;
      case Gender.female:
        iconData = Icons.female;
        iconColor = Colors.pink;
        break;
      case Gender.other:
        iconData = Icons.transgender;
        iconColor = Colors.purple;
        break;
    }

    return Icon(iconData, color: iconColor, size: 22);
  }

  void _showAddSkillDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddSkillBottomSheet(),
    );
  }
}
