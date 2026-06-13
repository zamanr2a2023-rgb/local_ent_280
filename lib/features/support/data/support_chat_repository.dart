import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/support/data/models/chat_message.dart';

class SupportChatRepository {
  SupportChatRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final bool disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<ChatMessage>> watchThreadMessages(String threadId) {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('chatThreads')
        .doc(threadId)
        .collection('chatMessages')
        .orderBy('createdAt', descending: false)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs.map(ChatMessage.fromFirestore).toList(),
        );
  }

  String generateMessageId(String threadId) {
    return _db
        .collection('chatThreads')
        .doc(threadId)
        .collection('chatMessages')
        .doc()
        .id;
  }
}
