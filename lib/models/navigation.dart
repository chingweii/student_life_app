import 'package:flutter/material.dart';
import 'package:student_life_app/screens/faq_chatbot/chatbot_screen.dart';

import 'package:student_life_app/screens/home_screen.dart';
import 'package:student_life_app/screens/profile/profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student_life_app/screens/messaging/chatlist.dart';
import 'package:student_life_app/screens/clubs/calendar_screen.dart';
import 'package:student_life_app/screens/skill_exchange_platform/search_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  // Replace these placeholder widgets with your actual screens
  static const List<Widget> _pages = <Widget>[
    ChatList(), // Index 0
    SearchScreen(), // Index 1
    ChatbotScreen(), // Index 2
    CalendarScreen(), // Index 3
    ProfileScreen(), // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        // --- STYLING TO MATCH YOUR DESIGN ---
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        showSelectedLabels: false, // Hides text labels
        showUnselectedLabels: false, // Hides text labels
        elevation: 0, // Removes the shadow
        // --- THE NAVIGATION ITEMS ---
        items: <BottomNavigationBarItem>[
          _buildNavItem('assets/icons/messaging.svg', 0),
          _buildNavItem('assets/icons/search.svg', 1),
          _buildNavItem('assets/icons/chatbox.png', 2),
          _buildNavItem('assets/icons/calendar.png', 3),
          _buildNavItem('assets/icons/user.png', 4),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetName, int index) {
    Widget buildIcon(String path, Color color) {
      if (path.endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      } else {
        return Image.asset(path, width: 28, height: 28, color: color);
      }
    }

    return BottomNavigationBarItem(
      // The icon when it's NOT selected
      icon: buildIcon(assetName, Colors.black54),

      // The custom widget for the icon when it IS selected
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
          // The icon itself
          buildIcon(assetName, Colors.black),
        ],
      ),
      label: '',
    );
  }
}
