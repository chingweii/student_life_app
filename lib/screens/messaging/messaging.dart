import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessagingScreen(),
    ),
  );
}

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  // Colors extracted from the image
  final Color _senderColor = const Color(0xFF867F95); // Muted Purple
  final Color _receiverColor = const Color(0xFFEAEAEA); // Light Grey
  final Color _backgroundColor = const Color(0xFFFFFFFF); // White

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0.5, // Slight shadow line
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            // Handle back action
          },
        ),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                "Cheryl Tan Mei Ling",
                style: TextStyle(
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
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ),
              // Replace with your actual asset image
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat List Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  // Date Stamp
                  const Center(
                    child: Text(
                      "Nov 30, 2023, 9:41 AM",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message 1 (Sender)
                  _buildSenderMessage("Hi, I'm Jie Er, nice to meet you!"),

                  const SizedBox(height: 20),

                  // Message Group 1 (Receiver)
                  _buildReceiverGroup([
                    "Heyy",
                    "I'm Mei Ling",
                    "Nice to meet you too!",
                  ]),

                  const SizedBox(height: 20),

                  // Message Group 2 (Sender)
                  _buildSenderMessage(
                    "I found that you used to be an emcee in quite a lot of event and I wish to practice my public speaking!",
                  ),
                  const SizedBox(height: 5),
                  _buildSenderMessage(
                    "And you are looking for a computer science study partner right?",
                  ),

                  const SizedBox(height: 20),

                  // Message Group 2 (Receiver)
                  _buildReceiverGroup([
                    "Oh ya!",
                    "It's great someone willing to reach out to me...",
                    "When are you free so we can meet physically for further discussion?",
                  ]),
                ],
              ),
            ),

            // Bottom Input Bar
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // Widget for Sender Bubbles (Purple, Right Aligned)
  Widget _buildSenderMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 4,
          left: 60,
        ), // Left margin to prevent full width
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

  // Widget for Receiver Groups (Avatar + Multiple Grey Bubbles)
  Widget _buildReceiverGroup(List<String> messages) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages.map((msg) {
              return Container(
                margin: const EdgeInsets.only(bottom: 4, right: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _receiverColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  msg,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget for the Bottom Input Field
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
              child: const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Icon(Icons.mic_none_outlined, color: Colors.grey, size: 28),
          const SizedBox(width: 15),
          const Icon(
            Icons.sentiment_satisfied_alt_outlined,
            color: Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 15),
          const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}
