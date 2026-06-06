import 'package:flutter/material.dart';
import '../model/project_model.dart';
import '../service/firestore_service.dart';

class ProjectProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  // Lắng nghe danh sách dự án của user
  void listenToProjects(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamProjects(userId).listen((projectList) {
      _projects = projectList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Tạo dự án mới
  Future<void> createProject(String title, String description, String ownerId, [List<String>? inviteEmails]) async {
    ProjectModel newProject = ProjectModel(
      projectId: '', // Firestore sẽ tự tạo
      title: title,
      description: description,
      ownerId: ownerId,
      members: [ProjectMember(userId: ownerId, role: 'owner')],
      createdAt: DateTime.now(),
    );
    String newId = await _firestoreService.createProject(newProject);

    if (inviteEmails != null && inviteEmails.isNotEmpty) {
      for (String email in inviteEmails) {
        if (email.trim().isNotEmpty) {
          await inviteMember(newId, email.trim(), 'member');
        }
      }
    }
  }

  // Lấy vai trò của user trong dự án
  String getUserRole(String projectId, String userId) {
    final project = _projects.firstWhere((p) => p.projectId == projectId, 
      orElse: () => ProjectModel(projectId: '', title: '', description: '', ownerId: '', members: [], createdAt: DateTime.now()));
    
    if (project.ownerId == userId) return 'owner';
    
    final member = project.members.firstWhere((m) => m.userId == userId, 
      orElse: () => ProjectMember(userId: '', role: 'member'));
    
    return member.role;
  }

  // Mời thành viên mới
  Future<void> inviteMember(String projectId, String email, String role) async {
    await _firestoreService.addMember(projectId, email, role);
  }

  // Tham gia dự án bằng mã (ID)
  Future<void> joinProjectByCode(String projectId, String userId) async {
    await _firestoreService.joinProjectByCode(projectId, userId);
  }



  // Quản lý (Chỉ Owner/Manager)
  Future<void> updateProject(String projectId, String newTitle, String newDesc) async {
    await _firestoreService.updateProject(projectId, {'title': newTitle, 'description': newDesc});
  }

  Future<void> deleteProject(String projectId, List<String> memberIds) async {
    await _firestoreService.deleteProject(projectId, memberIds);
  }

  Future<void> removeMember(String projectId, String userId) async {
    await _firestoreService.removeMember(projectId, userId);
  }

  Future<void> updateMemberRole(String projectId, String userId, String newRole) async {
    await _firestoreService.updateMemberRole(projectId, userId, newRole);
  }
}
