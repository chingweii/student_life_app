import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Required for time formatting
import 'package:student_life_app/screens/messaging/messaging.dart'; // Update path if needed

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // 1. Remove the Back Button
        automaticallyImplyLeading: false,

        // 2. Move Title to the Left
        centerTitle: false,
        titleSpacing: 20, // Adds a little padding so it's not glued to the edge

        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildFriendRequestIcon(), const SizedBox(width: 16)],
      ),
      body: _buildChatList(),
    );
  }

  // --- 1. FRIEND REQUEST ICON LOGIC ---
  Widget _buildFriendRequestIcon() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('friend_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        int requestCount = 0;
        if (snapshot.hasData) {
          requestCount = snapshot.data!.docs.length;
        }

        return IconButton(
          onPressed: () {},
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.people_alt_outlined,
                color: Colors.black,
                size: 28,
              ),
              if (requestCount > 0)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        requestCount > 100 ? "..." : "$requestCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. CHAT LIST LOGIC ---
  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading chats"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 10),
                Text(
                  "No messages yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var chatData = docs[index].data() as Map<String, dynamic>;
            var participants = List<String>.from(chatData['participants']);

            // A. Identify the "Other" Person's UID
            String otherUserId = participants.firstWhere(
              (id) => id != currentUser!.uid,
              orElse: () => '',
            );

            // --- THE FIX STARTS HERE ---
            // If we couldn't find another person (e.g., bad data), skip this row.
            if (otherUserId.isEmpty) return const SizedBox.shrink();
            // --- THE FIX ENDS HERE ---
            Map<String, dynamic>? unreadCounts =
                chatData['unreadCounts'] as Map<String, dynamic>?;
            int myUnreadCount = 0;
            if (unreadCounts != null &&
                unreadCounts.containsKey(currentUser!.uid)) {
              myUnreadCount = unreadCounts[currentUser!.uid];
            }
            // B. Fetch the "Other" Person's Profile Data
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId) // This is now safe because we checked above
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return _buildLoadingTile();
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                String firstName = userData?['first_name'] ?? 'User';
                String lastName = userData?['last_name'] ?? '';
                String displayName = "$firstName $lastName".trim();
                if (displayName.isEmpty) displayName = "Unknown User";

                String imageUrl = userData?['profile_pic_url'] ?? '';

                return _buildChatTile(
                  context,
                  displayName,
                  imageUrl,
                  otherUserId,
                  chatData['lastMessage'] ?? '',
                  chatData['lastMessageTime'] as Timestamp?,
                  myUnreadCount,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String name,
    String imageUrl,
    String otherUid,
    String lastMessage,
    Timestamp? timestamp,
    int unreadCount, // <--- Add this parameter
  ) {
    // (Your existing time formatting logic remains here...)
    String timeText = "";
    if (timestamp != null) {
      /* ... keep your existing logic ... */
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        backgroundImage: imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : const AssetImage('assets/images/user_avatar.png')
                  as ImageProvider,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          // Optional: Bold the name if unread
          color: unreadCount > 0 ? Colors.black : Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            // Highlight message logic: Bold and Black if unread, Grey if read
            color: unreadCount > 0 ? Colors.black : Colors.grey[600],
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
      // --- UPDATED TRAILING SECTION ---
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. The Time
          Text(
            timeText,
            style: TextStyle(
              color: unreadCount > 0 ? Colors.green : Colors.grey[500],
              fontSize: 12,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 5),

          // 2. The Red Circle (Only if count > 0)
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                unreadCount > 99 ? "99+" : "$unreadCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      // -------------------------------
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingScreen(
              recipientName: name,
              recipientImage: imageUrl,
              recipientUid: otherUid,
            ),
          ),
        ).then((_) {
          // Optional: When they come BACK from the chat,
          // the StreamBuilder automatically refreshes, so the count disappears.
        });
      },
    );
  }

  Widget _buildLoadingTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(radius: 28, backgroundColor: Colors.grey),
      title: Container(width: 100, height: 16, color: Colors.grey[200]),
      subtitle: Container(
        width: 200,
        height: 14,
        margin: const EdgeInsets.only(top: 8),
        color: Colors.grey[100],
      ),
    );
  }
}
