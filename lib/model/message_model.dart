import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String projectId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.messageId,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      projectId: map['project_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      senderName: map['sender_name'] ?? 'Unknown',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
