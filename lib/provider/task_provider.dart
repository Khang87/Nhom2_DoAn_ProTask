import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import '../model/task_model.dart';
import 'dart:async';

class TaskProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    fetchAllTasks();
  }

  void fetchTasksByProject(String projectId) {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _firestore.getTasksByProject(projectId).listen((data) {
      _tasks = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  void fetchAllTasks() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _firestore.getAllTasks().listen((data) {
      _tasks = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _firestore.saveTask(task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore.saveTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _firestore.deleteTask(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
