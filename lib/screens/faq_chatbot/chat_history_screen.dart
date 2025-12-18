import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:student_life_app/screens/faq_chatbot/chatbot_screen.dart'; // Update path

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat History",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('chat_sessions')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No history found."));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String sessionId = docs[index].id;
              String preview = data['preview'] ?? 'New Chat';
              Timestamp? time = data['updatedAt'];

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  time != null
                      ? DateFormat('MMM d, h:mm a').format(time.toDate())
                      : "",
                ),
                onTap: () {
                  // Navigate to ChatbotScreen with this specific Session ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatbotScreen(sessionId: sessionId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
