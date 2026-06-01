import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { todo, in_progress, review, done }
enum TaskPriority { low, medium, high }

class AttachmentModel {
  final String fileName;
  final String fileUrl;
  final DateTime uploadedAt;

  AttachmentModel({required this.fileName, required this.fileUrl, required this.uploadedAt});

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      fileName: map['file_name'] ?? '',
      fileUrl: map['file_url'] ?? '',
      uploadedAt: (map['uploaded_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'file_name': fileName,
    'file_url': fileUrl,
    'uploaded_at': Timestamp.fromDate(uploadedAt),
  };
}

class TaskModel {
  final String taskId;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> assignees;
  final DateTime? startDate;
  final DateTime? dueDate;
  final List<AttachmentModel> attachments;
  final DateTime createdAt;

  TaskModel({
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignees,
    this.startDate,
    this.dueDate,
    this.attachments = const [],
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      taskId: id,
      projectId: map['project_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: TaskStatus.values.firstWhere((e) => e.toString().split('.').last == map['status'], orElse: () => TaskStatus.todo),
      priority: TaskPriority.values.firstWhere((e) => e.toString().split('.').last == map['priority'], orElse: () => TaskPriority.medium),
      assignees: List<String>.from(map['assignees'] ?? []),
      startDate: (map['start_date'] as Timestamp?)?.toDate(),
      dueDate: (map['due_date'] as Timestamp?)?.toDate(),
      attachments: (map['attachments'] as List?)?.map((a) => AttachmentModel.fromMap(a)).toList() ?? [],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'assignees': assignees,
      'start_date': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
