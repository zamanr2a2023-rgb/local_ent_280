import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatSenderRole { client, driver, admin, manager, ops, system, unknown }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderUserId,
    required this.senderRole,
    required this.senderDisplayName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String senderUserId;
  final ChatSenderRole senderRole;
  final String senderDisplayName;
  final String body;
  final DateTime? createdAt;

  bool get isFromStaff =>
      senderRole == ChatSenderRole.admin ||
      senderRole == ChatSenderRole.manager ||
      senderRole == ChatSenderRole.ops;

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      threadId: data['threadId'] as String? ?? '',
      senderUserId: data['senderUserId'] as String? ?? '',
      senderRole: _parseRole(data['senderRole'] as String?),
      senderDisplayName: data['senderDisplayName'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _timestamp(data['createdAt']),
    );
  }

  static ChatSenderRole _parseRole(String? raw) {
    return switch (raw) {
      'client' => ChatSenderRole.client,
      'driver' => ChatSenderRole.driver,
      'admin' => ChatSenderRole.admin,
      'manager' => ChatSenderRole.manager,
      'ops' => ChatSenderRole.ops,
      'system' => ChatSenderRole.system,
      _ => ChatSenderRole.unknown,
    };
  }

  static DateTime? _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

String supportRequestThreadId(String requestId) {
  final sanitized = requestId.trim().replaceAll('/', '_');
  return 'support_request_$sanitized';
}
