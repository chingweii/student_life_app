import 'package:flutter/material.dart';
import 'package:student_life_app/screens/welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings", style: TextStyle(fontSize: 22))),
      body: Column(
        children: [
          // This expands to fill all available space, pushing the button to the bottom
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text("Edit Profile"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to Edit Profile Screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text("Privacy & Security"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to Privacy Screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text("Notifications"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to Notifications Screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text("Help & Support"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to Help Screen
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Center(
              // This widget centers the button horizontally
              child: TextButton.icon(
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  // Optional: This padding makes the button tap area bigger
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  // --- THIS IS THE LOG OUT NAVIGATION ---
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (Route<dynamic> route) =>
                        false, // Removes all previous routes
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
