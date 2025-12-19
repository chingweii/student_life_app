import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_life_app/screens/profile/settings_screen.dart';
import 'package:student_life_app/screens/profile/add_skill_bottom_sheet.dart';
import 'package:student_life_app/screens/profile/edit_profile_screen.dart';
import 'package:student_life_app/screens/clubs/event_details_screen.dart';
import 'package:student_life_app/models/event_model.dart';
import 'all_registered_events_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // 1. REMOVED: The global Padding(horizontal: 24.0) is gone.
          // This allows the ListView to touch the right edge of the screen.
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 2. ADDED: Padding specifically for the Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildProfileStream(),
              ),

              const SizedBox(height: 40),

              // Events Section (Handles its own padding logic below)
              _buildRegisteredEventsStream(),

              const SizedBox(height: 40),

              // 2. ADDED: Padding specifically for the Skills Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSkillsStream(),
              ),

              // Add some bottom spacing so the last item isn't stuck to the bottom
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep _buildProfileStream and _buildProfileHeader EXACTLY the same) ...
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
          profilePicUrl,
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 243, 239, 239),
          radius: 70,
          backgroundImage: backgroundImage,
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

  Widget _buildRegisteredEventsStream() {
    return StreamBuilder<QuerySnapshot>(
      // Keep listening to the user's registrations
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('my_events')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading events');

        // 1. Basic loading state for the stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];

        // 2. Title Row (Keep your existing styling)
        final titleRow = Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllRegisteredEventsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );

        if (docs.isEmpty) {
          return Column(
            children: [
              titleRow,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "No registered events.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ],
          );
        }

        // 3. Collect all the 'get' requests into a list of Futures
        List<Future<DocumentSnapshot>> futureEvents = docs.map((doc) {
          final userEventData = doc.data() as Map<String, dynamic>;
          final eventId = userEventData['eventId'];
          return FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();
        }).toList();

        // 4. Wait for ALL events to load so we can sort them
        return Column(
          children: [
            titleRow,
            SizedBox(
              height: 140,
              // Use FutureBuilder to resolve the list of events
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait(futureEvents),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    // Show a few loading skeletons while waiting
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: List.generate(
                        3,
                        (index) => _buildLoadingEventCard(),
                      ),
                    );
                  }

                  if (!futureSnapshot.hasData) return const SizedBox.shrink();

                  // 5. Convert snapshots to Event objects
                  List<Event> eventsList = [];
                  for (var eventDoc in futureSnapshot.data!) {
                    if (eventDoc.exists) {
                      eventsList.add(
                        Event.fromFirestore(
                          eventDoc.data() as Map<String, dynamic>,
                          eventDoc.id,
                        ),
                      );
                    }
                  }

                  // 6. SORTING MAGIC: Sort by date (ascending)
                  // This puts the earliest date (nearest) at the left.
                  eventsList.sort((a, b) => a.date.compareTo(b.date));

                  // Optional: If you want to hide past events, uncomment this:
                  // eventsList = eventsList.where((e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();

                  if (eventsList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: Text("Events details unavailable."),
                    );
                  }

                  // 7. Render the sorted list
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: eventsList.length,
                    itemBuilder: (context, index) {
                      return _buildRegisteredEventCard(eventsList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingEventCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildRegisteredEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFEF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${event.date.day}/${event.date.month}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    event.time.split(' to ')[0],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Going",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

            ...docs.map((doc) {
              var skillData = doc.data() as Map<String, dynamic>;
              return _buildSkillCard(
                doc.id,
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

  // ... (Keep _buildSkillCard, _buildGenderIcon, and _showAddSkillDialog exactly the same) ...
  Widget _buildSkillCard(
    String docId,
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
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('skills')
                    .doc(docId)
                    .delete();

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
