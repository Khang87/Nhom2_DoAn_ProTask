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

  ProjectModel({
    required this.projectId,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.createdAt,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'owner_id': ownerId,
      'members': members.map((m) => m.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
