import 'package:flutter/material.dart';

import 'package:student_life_app/screens/home_screen.dart';
import 'package:student_life_app/screens/profile/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  // Replace these placeholder widgets with your actual screens
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Chat Screen')), // Index 0
    Center(child: Text('Search Screen')), // Index 1
    Center(child: Text('Help Screen')), // Index 2
    Center(child: Text('Calendar Screen')), // Index 3
    Center(child: Text('Profile Screen')), // Index 4
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
          _buildNavItem('assets/icons/chatbot.svg', 2),
          _buildNavItem('assets/icons/calendar.svg', 3),
          _buildNavItem('assets/icons/user.svg', 4),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // --- HELPER METHOD TO BUILD EACH ITEM ---
  BottomNavigationBarItem _buildNavItem(String assetName, int index) {
    return BottomNavigationBarItem(
      // The icon when it's NOT selected
      icon: SvgPicture.asset(
        // Use SvgPicture.asset here
        assetName,
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(
          Colors.black54, // Lighter color
          BlendMode.srcIn,
        ),
      ),
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
          SvgPicture.asset(
            // And also use SvgPicture.asset here
            assetName,
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(
              Colors.black, // Darker color
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
      label: '',
    );
  }
}
