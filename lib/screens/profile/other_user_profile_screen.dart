import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

class OtherUserProfileScreen extends StatefulWidget {
  final String userID;

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
        // 1. We move the Main StreamBuilder to the top level
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userID)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: Text("User not found."));
            }

            // 2. Extract User Data & Simple Skills Array
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> simpleSkillsArray = userData['skills'] ?? [];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pass the extracted data to the header builder
                    _buildHeaderFromData(userData),
                    const SizedBox(height: 30),

                    // 3. Pass the Simple Array to the Skills builder
                    _buildUnifiedSkillsSection(simpleSkillsArray),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Header Logic ---
  Widget _buildHeaderFromData(Map<String, dynamic> data) {
    String firstName = data['first_name'] ?? '';
    String lastName = data['last_name'] ?? '';
    String fullName = '$firstName $lastName'.trim();
    String degree = data['degree'] ?? 'Degree';
    String location = data['location'] ?? 'Location';
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

    return _buildCenteredHeaderUI(
      fullName,
      degree,
      location,
      genderEnum,
      profilePicUrl,
    );
  }

  Widget _buildCenteredHeaderUI(
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
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 243, 239, 239),
          radius: 60,
          backgroundImage: backgroundImage,
        ),
        const SizedBox(height: 16),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              degree,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Friend Request Sent!")),
                );
              },
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text("Add Friend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A84A3),
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
            OutlinedButton(
              onPressed: () {},
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

  // --- Unified Skills Logic ---
  Widget _buildUnifiedSkillsSection(List<dynamic> simpleSkillsArray) {
    return StreamBuilder<QuerySnapshot>(
      // 1. Try to fetch from the 'skills' SUBCOLLECTION first
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('skills')
          .snapshots(),
      builder: (context, snapshot) {
        // Prepare list of widgets to display
        List<Widget> skillWidgets = [];
        bool hasSubcollectionData = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          hasSubcollectionData = true;
          // CASE A: User has Detailed Skills (Subcollection)
          skillWidgets = snapshot.data!.docs.map((doc) {
            var skillData = doc.data() as Map<String, dynamic>;
            return _buildReadOnlySkillCard(
              title: skillData['title'] ?? 'No Title',
              subtitle: skillData['subtitle'],
              proficiency: skillData['proficiency'],
              description: skillData['description'],
            );
          }).toList();
        }

        // CASE B: If NO subcollection data, check the Simple Array
        if (!hasSubcollectionData && simpleSkillsArray.isNotEmpty) {
          skillWidgets = simpleSkillsArray.map((skillTitle) {
            return _buildReadOnlySkillCard(
              title: skillTitle.toString(),
              // No subtitle/desc available for simple array skills
              subtitle: null,
              proficiency: null,
              description: null,
            );
          }).toList();
        }

        return Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            if (skillWidgets.isEmpty)
              const Text(
                "No skills added yet.",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...skillWidgets,
          ],
        );
      },
    );
  }

  Widget _buildReadOnlySkillCard({
    required String title,
    String? subtitle,
    String? proficiency,
    String? description,
  }) {
    String secondLine = '';
    if (subtitle != null && subtitle.isNotEmpty) {
      secondLine = subtitle;
    }
    if (proficiency != null && proficiency.isNotEmpty) {
      if (secondLine.isNotEmpty) {
        secondLine += ' • $proficiency';
      } else {
        secondLine = proficiency;
      }
    }

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
                  if (secondLine.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      secondLine,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 68, 68, 68),
                      ),
                    ),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ],
              ),
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
}
