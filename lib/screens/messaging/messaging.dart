import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  final String recipientName;
  final String recipientImage;

  const MessagingScreen({
    super.key,
    required this.recipientName,
    required this.recipientImage,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final Color _senderColor = const Color(0xFF867F95);
  final Color _backgroundColor = const Color(0xFFFFFFFF);

  // 1. Controller to read the text field
  final TextEditingController _messageController = TextEditingController();

  // 2. List to store messages.
  // We start with a welcome message. 'isSender': true means 'Me'.
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add an initial greeting
    _messages.add({
      'text': "Hi ${widget.recipientName}! I found you on the search page.",
      'isSender': true,
    });
  }

  @override
  void dispose() {
    _messageController.dispose(); // Clean up controller
    super.dispose();
  }

  // 3. Function to handle sending
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isSender': true, // New messages are always from "Me"
      });
      _messageController.clear(); // Clear the input box
    });
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
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.recipientImage),
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 4. Dynamic Chat List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  // Use specific builder based on who sent it
                  if (msg['isSender']) {
                    return _buildSenderMessage(msg['text']);
                  } else {
                    return _buildReceiverMessage(msg['text']);
                  }
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _senderColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  // Added a receiver builder just in case you expand later
  Widget _buildReceiverMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
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
                controller: _messageController, // 5. Connected Controller
                decoration: const InputDecoration(
                  hintText: "Message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 5),
                ),
                // Allow sending by pressing "Enter" on keyboard
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // 6. Connected Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Color(0xFF867F95), size: 28),
          ),
        ],
      ),
    );
  }
}
