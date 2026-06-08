import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/task_model.dart';
import '../service/firestore_service.dart';
import '../service/storage_service.dart';
class TaskProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Lắng nghe tất cả task của các dự án mà user tham gia
  void listenToAllTasks(List<String> projectIds) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamAllUserTasks(projectIds).listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Compatibility method for older screens - now calls the real logic
  Future<void> fetchAllTasks() async {
    // This is now handled by listenToAllTasks called from screens or home
  }

  void listenToTasks(String projectId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamTasks(projectId).listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createTask(TaskModel task, {List<File>? localFiles}) async {
    String taskId = await _firestoreService.createTask(task);
    
    if (localFiles != null && localFiles.isNotEmpty) {
      List<AttachmentModel> uploadedAttachments = [];
      final storageService = StorageService();
      
      for (var file in localFiles) {
        AttachmentModel? attachment = await storageService.uploadFile('tasks/$taskId', file);
        if (attachment != null) {
          uploadedAttachments.add(attachment);
        }
      }
      
      if (uploadedAttachments.isNotEmpty) {
        await _firestoreService.updateTaskAttachments(taskId, uploadedAttachments);
      }
    }
  }

  Future<void> updateStatus(String taskId, TaskStatus newStatus) async {
    await _firestoreService.updateTaskStatus(taskId, newStatus);
  }

  Future<void> updateTaskDetails(
    String taskId,
    String title,
    String description,
    TaskPriority priority,
    List<String> assignees,
    DateTime? dueDate,
    double progress,
    List<AttachmentModel> attachments,
  ) async {
    await _firestoreService.updateTaskDetails(taskId, {
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'assignees': assignees,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'progress': progress,
      'attachments': attachments.map((a) => a.toMap()).toList(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}
