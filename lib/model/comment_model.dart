import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      commentId: id,
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
