// lib/models/chatbot_message.dart
enum ChatUser { user, bot }

class ChatbotMessage {
  final String text;
  final ChatUser user;
  final String avatarUrl;

  ChatbotMessage({
    required this.text,
    required this.user,
    required this.avatarUrl,
  });
}
