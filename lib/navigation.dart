import 'package:flutter/material.dart';
import 'package:student_life_app/screens/faq_chatbot/chatbot_screen.dart';
import 'package:student_life_app/screens/profile/profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student_life_app/screens/messaging/chatlist.dart';
import 'package:student_life_app/screens/clubs/calendar_screen.dart';
import 'package:student_life_app/screens/skill_exchange_platform/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

  static const List<Widget> _pages = <Widget>[
    ChatsListScreen(),
    SearchScreen(),
    CalendarScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- NEW: Stream to calculate TOTAL unread messages ---
  Stream<int> get _totalUnreadCountStream {
    if (currentUid == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            var data = doc.data();
            // Check if unreadCounts exists and has our ID
            if (data.containsKey('unreadCounts')) {
              var counts = data['unreadCounts'] as Map<String, dynamic>;
              if (counts.containsKey(currentUid)) {
                // Add to total
                total += (counts[currentUid] as num).toInt();
              }
            }
          }
          return total;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),

      // --- WRAP BottomNavigationBar IN STREAM BUILDER ---
      bottomNavigationBar: StreamBuilder<int>(
        stream: _totalUnreadCountStream,
        builder: (context, snapshot) {
          int totalUnread = 0;
          if (snapshot.hasData) {
            totalUnread = snapshot.data!;
          }

          return BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: <BottomNavigationBarItem>[
              // --- 1. Pass the badge count specifically to the Messaging Icon ---
              _buildNavItem(
                'assets/icons/messaging.svg',
                0,
                badgeCount: totalUnread,
              ),

              _buildNavItem('assets/icons/search.svg', 1),
              _buildNavItem('assets/icons/calendar.png', 2),
              _buildNavItem('assets/icons/chatbox.png', 3),
              _buildNavItem('assets/icons/user.png', 4),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }

  // --- UPDATED HELPER: Added badgeCount parameter ---
  BottomNavigationBarItem _buildNavItem(
    String assetName,
    int index, {
    int badgeCount = 0, // Default is 0 (no badge)
  }) {
    // Internal helper to generate the Icon (with or without badge)
    Widget buildIconWithBadge(String path, Color color) {
      Widget baseIcon;

      // 1. Create the base icon (SVG or Image)
      if (path.endsWith('.svg')) {
        baseIcon = SvgPicture.asset(
          path,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      } else {
        baseIcon = Image.asset(path, width: 28, height: 28, color: color);
      }

      // 2. If no badge needed, return just the icon
      if (badgeCount == 0) {
        return baseIcon;
      }

      // 3. If badge needed, wrap in Stack
      return Stack(
        clipBehavior: Clip.none,
        children: [
          baseIcon,
          Positioned(
            right: -6, // Move to right
            top: -6, // Move to top
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  badgeCount > 99 ? "99+" : "$badgeCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return BottomNavigationBarItem(
      // Use the helper for the inactive state
      icon: buildIconWithBadge(assetName, Colors.black54),

      // Use the helper for the active state
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          // We also show the badge when the icon is active (black)
          buildIconWithBadge(assetName, Colors.black),
        ],
      ),
      label: '',
    );
  }
}
