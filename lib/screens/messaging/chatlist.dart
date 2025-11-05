import 'package:flutter/material.dart';
import 'package:student_life_app/models/chat_message.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // 1. State variables to manage loading and data
  bool _isLoading = true;
  List<ChatMessage> _chatMessages = []; // Start with an empty list

  @override
  void initState() {
    super.initState();
    _fetchChatData(); // Call the method to "fetch" data when the screen loads
  }

  // 2. Placeholder function to simulate fetching data
  Future<void> _fetchChatData() async {
    // Simulate a network delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // When you have your real data, you will fetch it here.
    // For now, we'll just update the state to stop loading.
    // If you want, you could populate `_chatMessages` with mock data here.

    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 30.0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // loading state
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show spinner while loading
            )
          : _chatMessages.isEmpty
          ? const Center(
              child: Text(
                'No chats yet.', // Show this message if the list is empty
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chat = _chatMessages[index];
                // Your ListTile code to display the chat item goes here
                return ListTile(
                  leading: CircleAvatar(radius: 28),
                  title: Text(chat.name),
                  subtitle: Text(chat.lastMessage),
                  trailing: Text(chat.time),
                );
              },
            ),
    );
  }
}
