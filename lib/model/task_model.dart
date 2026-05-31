class TaskModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assigneeId;
  final String status; // Todo, In Progress, Done
  final DateTime deadline;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.status,
    required this.deadline,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'] ?? '',
      assigneeId: map['assigneeId'] ?? '',
      status: map['status'] ?? 'Todo',
      deadline: DateTime.parse(map['deadline'] ?? DateTime.now().toIso8601String()),
      isDone: map['isDone'] == 1,
    );
  }
}
