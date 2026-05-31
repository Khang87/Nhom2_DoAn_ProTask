class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String members;
  final double progress;
  final DateTime deadline;
  final int color;
  final String? link;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.progress,
    required this.deadline,
    required this.color,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'members': members,
      'progress': progress,
      'deadline': deadline.toIso8601String(),
      'color': color,
      'link': link,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      members: map['members'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      deadline: DateTime.parse(map['deadline'] ?? DateTime.now().toIso8601String()),
      color: map['color'] ?? 0xFF2196F3,
      link: map['link'],
    );
  }
}
