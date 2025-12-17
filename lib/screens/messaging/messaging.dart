import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessagingScreen extends StatefulWidget {
  final String recipientName;
  final String recipientImage;
  final String recipientUid; // <--- NEW: We need the ID to know who to talk to

  const MessagingScreen({
    super.key,
    required this.recipientName,
    required this.recipientImage,
    required this.recipientUid,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colors
  final Color _senderColor = const Color(0xFF867F95);
  final Color _backgroundColor = const Color(0xFFFFFFFF);

  late String chatId;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;

    // 1. GENERATE CONSISTENT CHAT ID
    // We sort the UIDs so "UserA_UserB" is the same as "UserB_UserA"
    // This ensures both people enter the EXACT same chat room.
    List<String> ids = [currentUserId, widget.recipientUid];
    ids.sort();
    chatId = ids.join("_");
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // 2. SEND MESSAGE TO FIRESTORE
  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear(); // Clear UI immediately for better UX

    // A. Add message to the 'messages' sub-collection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'receiverId': widget.recipientUid,
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // B. Update the 'Chat Room' metadata (for your future Inbox list)
    // We use set with merge: true so it creates the doc if it doesn't exist
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, widget.recipientUid],
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Helper to safely load images (Mock vs Real)
  ImageProvider _getProfileImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
    return const AssetImage('assets/images/user_avatar.png');
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  String _getDateHeader(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();

    // Check if it's today
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return "Today";
    }

    // Check if it's yesterday
    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day) {
      return "Yesterday";
    }

    // Otherwise, return formatted date like "Thu, 25 December 2025"
    return DateFormat('EEE, dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: _getProfileImage(widget.recipientImage),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.recipientName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3. REAL-TIME STREAM
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false) // Oldest at top
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading messages"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      bool isSender = data['senderId'] == currentUserId;
                      Timestamp? time = data['timestamp'] as Timestamp?;

                      // --- DATE HEADER LOGIC ---
                      bool showDateHeader = false;
                      if (index == 0) {
                        // First message always shows date
                        showDateHeader = true;
                      } else {
                        // Check if previous message was on a different day
                        var prevData =
                            docs[index - 1].data() as Map<String, dynamic>;
                        Timestamp? prevTime =
                            prevData['timestamp'] as Timestamp?;

                        if (time != null && prevTime != null) {
                          DateTime currentDate = time.toDate();
                          DateTime prevDate = prevTime.toDate();

                          if (currentDate.year != prevDate.year ||
                              currentDate.month != prevDate.month ||
                              currentDate.day != prevDate.day) {
                            showDateHeader = true;
                          }
                        }
                      }
                      // -------------------------

                      // Create the Message Bubble
                      Widget messageWidget;
                      if (isSender) {
                        messageWidget = _buildSenderMessage(
                          data['text'] ?? '',
                          time,
                        );
                      } else {
                        messageWidget = _buildReceiverMessage(
                          data['text'] ?? '',
                          time,
                        );
                      }

                      // Return Column if we need a Date Header, otherwise just the message
                      if (showDateHeader && time != null) {
                        return Column(
                          children: [
                            _buildDateHeader(_getDateHeader(time)),
                            messageWidget,
                          ],
                        );
                      } else {
                        return messageWidget;
                      }
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300], // Light grey background like WhatsApp
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSenderMessage(String message, Timestamp? timestamp) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        // UPDATED MARGIN: Changed right from 16 to 8
        margin: const EdgeInsets.only(bottom: 10, left: 60, right: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // THE BUBBLE
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _senderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            // THE TIME
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 0),
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverMessage(String message, Timestamp? timestamp) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        // UPDATED MARGIN: Changed left from 16 to 8
        margin: const EdgeInsets.only(bottom: 10, left: 0, right: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THE BUBBLE
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ),

            // THE TIME
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 0),
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 5),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Color(0xFF867F95), size: 28),
          ),
        ],
      ),
    );
  }
}
