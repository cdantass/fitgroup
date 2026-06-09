class ChatMessage {
  final String? id;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    required this.senderUid,
    required this.senderName,
    required this.text,
    this.createdAt,
  });
}
