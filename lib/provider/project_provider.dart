import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import '../model/project_model.dart';
import 'dart:async';

class ProjectProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectProvider() {
    fetchProjects();
  }

  void fetchProjects() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _firestore.getProjects().listen((data) {
      _projects = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addProject(ProjectModel project) async {
    await _firestore.saveProject(project);
  }

  Future<void> deleteProject(String id) async {
    await _firestore.deleteProject(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
