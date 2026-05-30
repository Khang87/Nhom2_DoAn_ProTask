import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PROJECTS ---
  Future<void> saveProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).set(project.toMap());
  }

  Stream<List<ProjectModel>> getProjects() {
    return _db.collection('projects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data())).toList());
  }

  Future<void> deleteProject(String id) async {
    await _db.collection('projects').doc(id).delete();
    // Xóa tất cả task thuộc project này
    var tasks = await _db.collection('tasks').where('projectId', isEqualTo: id).get();
    for (var doc in tasks.docs) {
      await doc.reference.delete();
    }
  }

  // --- TASKS ---
  Future<void> saveTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).set(task.toMap());
  }

  Stream<List<TaskModel>> getTasksByProject(String projectId) {
    return _db.collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList());
  }

  Stream<List<TaskModel>> getAllTasks() {
    return _db.collection('tasks').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList());
  }

  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }
}
