class ChatMessage {
  final String author;
  final String text;
  final bool isMe;
  final DateTime time;

  const ChatMessage({
    required this.author,
    required this.text,
    required this.isMe,
    required this.time,
  });
}
