import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

class OtherUserProfileScreen extends StatefulWidget {
  final String userID; // The ID of the person we are viewing

  const OtherUserProfileScreen({super.key, required this.userID});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center everything
              children: [
                _buildProfileStream(),
                const SizedBox(height: 30),
                // Reusing the skills stream logic, but pointing to the OTHER user
                _buildSkillsStream(),
              ],
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
          .doc(widget.userID) // Fetching data for the specific User ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("User not found.");
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        String firstName = data['first_name'] ?? '';
        String lastName = data['last_name'] ?? '';
        String fullName = '$firstName $lastName'.trim();
        String degree = data['degree'] ?? 'Degree';
        String location = data['location'] ?? 'Location';
        String? profilePicUrl = data['profile_pic_url'];

        // Gender Logic
        String genderString = data['gender'] ?? 'other';
        Gender genderEnum;
        if (genderString.toLowerCase() == 'male') {
          genderEnum = Gender.male;
        } else if (genderString.toLowerCase() == 'female') {
          genderEnum = Gender.female;
        } else {
          genderEnum = Gender.other;
        }

        return _buildCenteredHeader(
          fullName,
          degree,
          location,
          genderEnum,
          profilePicUrl,
        );
      },
    );
  }

  Widget _buildCenteredHeader(
    String name,
    String degree,
    String location,
    Gender gender,
    String? imageUrl,
  ) {
    ImageProvider backgroundImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      backgroundImage = NetworkImage(imageUrl);
    } else {
      backgroundImage = const AssetImage('assets/images/user_avatar.png');
    }

    return Column(
      children: [
        // 1. Profile Picture (Centered)
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 243, 239, 239),
          radius: 60, // Slightly smaller than personal profile for balance
          backgroundImage: backgroundImage,
        ),
        const SizedBox(height: 16),

        // 2. Name + Gender Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name.isEmpty ? "User" : name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            _buildGenderIcon(gender),
          ],
        ),
        const SizedBox(height: 8),

        // 3. Course and Location (Same Horizontal Line)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              degree,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 12), // Spacing between items
            const SizedBox(width: 12),
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 4. Action Buttons (Add Friend & More)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Friend Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Add Friend Logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Friend Request Sent!")),
                );
              },
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text("Add Friend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF8A84A3,
                ), // Your app theme color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // More Options (Three dots)
            OutlinedButton(
              onPressed: () {
                // TODO: Show bottom sheet options (Report, Block, etc.)
              },
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsStream() {
    return StreamBuilder<QuerySnapshot>(
      // Fetching from the OTHER user's subcollection
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('skills')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading skills');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var docs = snapshot.data?.docs ?? [];

        return Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills', // Changed from "My Skills"
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            if (docs.isEmpty)
              const Text(
                "No skills added yet.",
                style: TextStyle(color: Colors.grey),
              ),

            ...docs.map((doc) {
              var skillData = doc.data() as Map<String, dynamic>;
              return _buildReadOnlySkillCard(
                skillData['title'] ?? 'No Title',
                skillData['subtitle'] ?? '',
                skillData['description'] ?? '',
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Same visual design as your profile, but NO Delete button
  Widget _buildReadOnlySkillCard(
    String title,
    String subtitle,
    String description,
  ) {
    return Card(
      color: const Color.fromARGB(255, 243, 239, 239),
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0, // Flatter look for public view
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
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ],
              ),
            ),
            // Removed the Delete Icon Button here
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
}
