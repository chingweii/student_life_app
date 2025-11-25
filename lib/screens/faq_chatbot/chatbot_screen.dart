import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_life_app/models/chatbot_message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatbotMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.0-flash-exp',
    systemInstruction: Content.system(
      'You are a helpful assistant for Sunway University. '
      'Your name is "Leo". '
      'You must only answer questions related to Sunway University, its clubs, events, academics, and campus life. '
      'If the user asks about anything else, politely decline by saying "I can only help with questions about Sunway University."',
    ),
  );

  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Start the chat session when the screen loads
    _chat = model.startChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.isEmpty) return;

    // 1. Add the user's message to the list
    final userMessage = ChatbotMessage(
      user: ChatUser.user,
      avatarUrl: 'assets/images/user_avatar.png',
      text: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true; // Show loading indicator
    });

    // 2. Clear the input field
    _textController.clear();

    _callGeminiAPI(text);
  }

  Future<void> _callGeminiAPI(String userQuery) async {
    try {
      // 1. Send the message using the ongoing chat session
      final response = await _chat.sendMessage(Content.text(userQuery));

      final botResponse = ChatbotMessage(
        user: ChatUser.bot,
        avatarUrl: 'assets/images/bot_avatar.png',
        text: response.text ?? "Sorry, I couldn't get a response.",
      );

      setState(() {
        _messages.add(botResponse);
      });
    } catch (e) {
      final errorResponse = ChatbotMessage(
        user: ChatUser.bot,
        avatarUrl: 'assets/images/bot_avatar.png',
        text: 'Error: ${e.toString()}',
      );
      setState(() {
        _messages.add(errorResponse);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/bot_avatar.png'),
                  ),
                  SizedBox(width: 8),
                  Text('Leo is typing...'),
                ],
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

  // copy paste of bot message
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
                      onPressed: () {
                        // 1. Get the text from the message object
                        final String textToCopy = message.text;

                        // 2. Use the Clipboard service to copy the text
                        Clipboard.setData(ClipboardData(text: textToCopy));

                        // 3. (Optional but recommended) Show a confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
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

  // history and regenerate response
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

  // input text bar
  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: InputBorder.none,
              ),
              onSubmitted: (value) => _handleSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.mic_none), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
