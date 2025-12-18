import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_life_app/models/chatbot_message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_life_app/screens/faq_chatbot/chat_history_screen.dart';

class ChatbotScreen extends StatefulWidget {
  final String? sessionId;

  const ChatbotScreen({super.key, this.sessionId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Session State
  String? _currentSessionId;
  late final GenerativeModel _model;
  ChatSession? _chat;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Variable to store the real user profile URL
  String? _userProfilePicUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _initializeModel();
    _setupSession();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Fetch User Profile Picture from Firestore ---
  Future<void> _fetchUserProfile() async {
    if (_uid == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          var data = userDoc.data() as Map<String, dynamic>;
          _userProfilePicUrl = data['profile_pic_url'];
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  // --- 1. INITIALIZATION ---
  void _initializeModel() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash-exp',
      systemInstruction: Content.system(
        'You are a helpful assistant for Sunway University named Leo. '
        'You have access to the current events and data from the app database provided in the context. '
        'Use the provided Context to answer questions about dates, times, and event details. '
        'If the answer is not in the context, say you do not have that information.',
      ),
    );
  }

  // --- 2. SESSION MANAGEMENT ---
  Future<void> _setupSession() async {
    if (_uid == null) return;

    if (widget.sessionId != null) {
      _currentSessionId = widget.sessionId;
      await _restoreChatHistoryForGemini();
    } else {
      var sessionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('chat_sessions')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (sessionSnapshot.docs.isNotEmpty) {
        _currentSessionId = sessionSnapshot.docs.first.id;
        await _restoreChatHistoryForGemini();
      } else {
        _createNewSession();
      }
    }
    setState(() {});
  }

  void _createNewSession() {
    _currentSessionId = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('chat_sessions')
        .doc()
        .id;

    _chat = _model.startChat();
    setState(() {});
  }

  Future<void> _restoreChatHistoryForGemini() async {
    if (_currentSessionId == null) return;

    try {
      final historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('chat_sessions')
          .doc(_currentSessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      List<Content> history = [];
      for (var doc in historySnapshot.docs) {
        final role = doc['role'] == 'user' ? 'user' : 'model';
        final text = doc['text'];
        if (role == 'user') {
          history.add(Content.text(text));
        } else {
          history.add(Content.model([TextPart(text)]));
        }
      }

      _chat = _model.startChat(history: history);
    } catch (e) {
      print("Error restoring history: $e");
      _chat = _model.startChat();
    }
  }

  // --- 3. APP KNOWLEDGE (ROBUST FETCH) ---
  Future<String> _fetchAppKnowledge() async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();
      if (eventsSnapshot.docs.isEmpty)
        return "System Context: No upcoming events.";

      StringBuffer buffer = StringBuffer();
      buffer.writeln("System Context (Current Database Data):");

      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final title =
            data['title'] ??
            data['eventName'] ??
            data['name'] ??
            'Untitled Event';
        final description = data['description'] ?? 'No description';
        final location = data['location'] ?? 'Unknown location';
        String timeString = "Time not specified";
        if (data['time'] != null)
          timeString = data['time'].toString();
        else if (data['date'] is Timestamp)
          timeString = (data['date'] as Timestamp).toDate().toString();

        buffer.writeln(
          "Event: $title\nTime: $timeString\nLocation: $location\nDetails: $description\n---",
        );
      }
      return buffer.toString();
    } catch (e) {
      return "System Context: Error accessing database.";
    }
  }

  // --- 4. SENDING MESSAGES ---
  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _currentSessionId == null) return;

    _textController.clear();
    setState(() => _isLoading = true);

    await _saveMessageToFirestore(text, 'user');
    await _callGeminiAPI(text);
  }

  Future<void> _callGeminiAPI(String userQuery) async {
    try {
      if (_chat == null) _chat = _model.startChat();

      String appContext = await _fetchAppKnowledge();
      String fullPrompt =
          """
      $appContext
      User Question: $userQuery
      """;

      final response = await _chat!.sendMessage(Content.text(fullPrompt));
      final botText = response.text ?? "Sorry, I couldn't get a response.";

      await _saveMessageToFirestore(botText, 'model');
    } catch (e) {
      await _saveMessageToFirestore("Error: ${e.toString()}", 'model');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMessageToFirestore(String text, String role) async {
    final sessionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('chat_sessions')
        .doc(_currentSessionId);

    await sessionRef.collection('messages').add({
      'text': text,
      'role': role,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await sessionRef.set({
      'preview': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- 5. UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Leobot',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _createNewSession,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentSessionId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_uid)
                        .collection('chat_sessions')
                        .doc(_currentSessionId)
                        .collection('messages')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      var docs = snapshot.data!.docs;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          bool isUser = data['role'] == 'user';

                          // --- UPDATED IMAGE LOGIC ---
                          String avatarToUse;
                          if (isUser) {
                            // If user, use the fetched URL, otherwise fallback to default
                            avatarToUse =
                                _userProfilePicUrl ??
                                'assets/images/user_avatar.png';
                          } else {
                            // If bot, use the specific app_icon
                            avatarToUse = 'assets/images/app_icon.jpg';
                          }

                          final message = ChatbotMessage(
                            user: isUser ? ChatUser.user : ChatUser.bot,
                            avatarUrl: avatarToUse,
                            text: data['text'] ?? '',
                          );

                          if (isUser) {
                            return _buildUserMessage(message);
                          } else {
                            return _buildBotMessage(message);
                          }
                        },
                      );
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
                  const CircleAvatar(
                    // Update loading icon too
                    backgroundImage: AssetImage('assets/images/app_icon.jpg'),
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Leo is checking the calendar...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          // --- REMOVED SUGGESTION CHIPS HERE ---
          _buildTextInput(),
        ],
      ),
    );
  }

  // --- 6. UI HELPERS ---

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

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
          CircleAvatar(backgroundImage: _getImageProvider(message.avatarUrl)),
        ],
      ),
    );
  }

  Widget _buildBotMessage(ChatbotMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: _getImageProvider(message.avatarUrl)),
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
                // --- MODIFIED: Added Regenerate Icon here ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.text));
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
                    // --- NEW REGENERATE ICON ---
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: "Regenerate Response",
                      onPressed: () {
                        // TODO: Implement regeneration logic
                        // Typically re-calls the API with the last user prompt
                      },
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

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.mic_none), onPressed: () {}),
          IconButton(icon: const Icon(Icons.send), onPressed: _handleSend),
        ],
      ),
    );
  }
}
