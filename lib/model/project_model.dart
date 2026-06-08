import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectMember {
  final String userId;
  final String role; // 'owner', 'manager', 'member'

  ProjectMember({required this.userId, required this.role});

  factory ProjectMember.fromMap(Map<String, dynamic> map) {
    return ProjectMember(
      userId: map['user_id'] ?? '',
      role: map['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() => {'user_id': userId, 'role': role};
}

class ProjectModel {
  final String projectId;
  final String title;
  final String description;
  final String ownerId;
  final List<ProjectMember> members;
  final DateTime createdAt;
  final DateTime? endDate;
  final double progress;
  final bool isCompleted;

  ProjectModel({
    required this.projectId,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    this.endDate,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      projectId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['owner_id'] ?? '',
      members: (map['members'] as List?)
              ?.map((m) => ProjectMember.fromMap(m))
              .toList() ??
          [],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['end_date'] as Timestamp?)?.toDate(),
      progress: (map['progress'] ?? 0.0).toDouble(),
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'owner_id': ownerId,
      'members': members.map((m) => m.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      if (endDate != null) 'end_date': Timestamp.fromDate(endDate!),
      'progress': progress,
      'is_completed': isCompleted,
    };
  }
}
