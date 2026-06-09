import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  static const String _collection = 'grupos';
  static const String _subcollection = 'mensagens';

  Stream<List<ChatMessage>> streamMessages(String groupId) {
    final messagesRef = FirebaseFirestore.instance
        .collection(_collection)
        .doc(groupId)
        .collection(_subcollection);

    return messagesRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          senderUid: data['senderUid'] as String? ?? '',
          senderName: data['senderName'] as String? ?? '',
          text: data['text'] as String? ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        );
      }).toList();

      messages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return aTime.compareTo(bTime);
      });

      return messages;
    });
  }

  Future<void> sendMessage(String groupId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final senderName = user.displayName ??
        user.email?.split('@').first ??
        'Usuário';

    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(groupId)
        .collection(_subcollection)
        .add({
      'senderUid': user.uid,
      'senderName': senderName,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
