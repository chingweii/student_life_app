import 'package:flutter/material.dart';
import 'package:student_life_app/models/chatbot_message.dart';

// In your chatbot screen file
final List<ChatbotMessage> mockMessages = [
  ChatbotMessage(
    user: ChatUser.user,
    avatarUrl: 'assets/images/user_avatar.png',
    text: 'What clubs are available at Sunway University?',
  ),
  ChatbotMessage(
    user: ChatUser.bot,
    avatarUrl: 'assets/images/bot_avatar.png',
    text:
        'Sunway University has a wide range of clubs, including academic clubs, cultural societies, sports teams, volunteering groups, and special interest clubs like photography or entrepreneurship. You can view the full list in the "Clubs & Societies" section of the app.',
  ),
  ChatbotMessage(
    user: ChatUser.user,
    avatarUrl: 'assets/images/user_avatar.png',
    text: 'How can I find out what events are happening this week?',
  ),
  ChatbotMessage(
    user: ChatUser.bot,
    avatarUrl: 'assets/images/bot_avatar.png',
    text:
        'Check the "Events" section for a calendar and list view of all upcoming events. You can filter by date, category, or club.',
  ),
];

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // Use the mock data for now
  final List<ChatbotMessage> _messages = mockMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'New Chat',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. The list of messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Conditionally build the message bubble
                if (message.user == ChatUser.user) {
                  return _buildUserMessage(message);
                } else {
                  return _buildBotMessage(message);
                }
              },
            ),
          ),

          // 2. The suggestion buttons
          _buildSuggestionChips(),

          // 3. The text input field
          _buildTextInput(),
        ],
      ),
    );
  }

  // Widget for the User's message bubble
  Widget _buildUserMessage(ChatbotMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(backgroundImage: AssetImage(message.avatarUrl)),
        ],
      ),
    );
  }

  // Widget for the Bot's message bubble
  Widget _buildBotMessage(ChatbotMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: AssetImage(message.avatarUrl)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the suggestion chips
  Widget _buildSuggestionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(onPressed: () {}, child: const Text('History')),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Regenerate Response'),
          ),
        ],
      ),
    );
  }

  // Widget for the bottom text input bar
  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.mic_none), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.image_outlined), onPressed: () {}),
        ],
      ),
    );
  }
}
