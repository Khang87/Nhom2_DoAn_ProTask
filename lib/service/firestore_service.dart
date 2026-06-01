import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';
import '../model/comment_model.dart';
import '../model/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER OPERATIONS ---
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return UserModel.fromMap(snap.data()!);
      }
      return null;
    });
  }

  // Lấy danh sách user từ danh sách UID
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      // split into chunks of 10 for Firestore 'whereIn' limitation
      List<UserModel> users = [];
      for (var i = 0; i < uids.length; i += 10) {
        var chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
        var snapshot = await _db.collection('users').where('uid', whereIn: chunk).get();
        users.addAll(snapshot.docs.map((doc) => UserModel.fromMap(doc.data())));
      }
      return users;
    } catch (e) {
      print("Lỗi lấy users: $e");
      return [];
    }
  }

  // --- PROJECT OPERATIONS ---
  Future<String> createProject(ProjectModel project) async {
    DocumentReference ref = await _db.collection('projects').add(project.toMap());
    // Cập nhật danh sách dự án của owner
    await _db.collection('users').doc(project.ownerId).update({
      'joined_projects': FieldValue.arrayUnion([ref.id])
    });
    return ref.id;
  }

  Stream<List<ProjectModel>> streamProjects(String userId) {
    return _db.collection('projects')
        .where('members', arrayContainsAny: [{'user_id': userId, 'role': 'owner'}, {'user_id': userId, 'role': 'manager'}, {'user_id': userId, 'role': 'member'}])
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList());
  }

  // --- CHAT OPERATIONS ---
  Future<void> sendChatMessage(String projectId, Map<String, dynamic> messageData) async {
    await _db.collection('projects').doc(projectId).collection('messages').add(messageData);
  }

  Stream<List<Map<String, dynamic>>> streamChatMessages(String projectId) {
    return _db.collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // Mời thành viên
  Future<void> addMember(String projectId, String userEmail, String role) async {
    // Tìm user theo email
    var userSnap = await _db.collection('users').where('email', isEqualTo: userEmail).limit(1).get();
    if (userSnap.docs.isNotEmpty) {
      String uid = userSnap.docs.first.id;
      await _db.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayUnion([{'user_id': uid, 'role': role}])
      });
      await _db.collection('users').doc(uid).update({
        'joined_projects': FieldValue.arrayUnion([projectId])
      });
    }
  }

  Future<void> joinProjectByCode(String projectId, String userId) async {
    // Thêm member với role mặc định là 'member'
    await _db.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayUnion([{'user_id': userId, 'role': 'member'}])
    });
    
    // Thêm project vào joined_projects của user
    await _db.collection('users').doc(userId).update({
      'joined_projects': FieldValue.arrayUnion([projectId])
    });
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    await _db.collection('projects').doc(projectId).update(data);
  }

  Future<void> deleteProject(String projectId, List<String> memberIds) async {
    // Xóa project khỏi danh sách joined_projects của tất cả member
    for (String userId in memberIds) {
      await _db.collection('users').doc(userId).update({
        'joined_projects': FieldValue.arrayRemove([projectId])
      });
    }
    // Xóa tất cả tasks của project này (không bắt buộc nếu dùng Subcollections nhưng chúng ta dùng Collection ngang hàng)
    var tasks = await _db.collection('tasks').where('project_id', isEqualTo: projectId).get();
    for (var doc in tasks.docs) {
      await doc.reference.delete();
    }
    // Xóa project
    await _db.collection('projects').doc(projectId).delete();
  }

  Future<void> removeMember(String projectId, String userId) async {
    var projectDoc = await _db.collection('projects').doc(projectId).get();
    if (projectDoc.exists) {
      List members = projectDoc.data()?['members'] ?? [];
      members.removeWhere((m) => m['user_id'] == userId);
      await _db.collection('projects').doc(projectId).update({'members': members});
      
      await _db.collection('users').doc(userId).update({
        'joined_projects': FieldValue.arrayRemove([projectId])
      });
    }
  }

  Future<void> updateMemberRole(String projectId, String userId, String newRole) async {
    var projectDoc = await _db.collection('projects').doc(projectId).get();
    if (projectDoc.exists) {
      List members = projectDoc.data()?['members'] ?? [];
      for (var i = 0; i < members.length; i++) {
        if (members[i]['user_id'] == userId) {
          members[i]['role'] = newRole;
        }
      }
      await _db.collection('projects').doc(projectId).update({'members': members});
    }
  }

  // --- TASK OPERATIONS ---
  Future<String> createTask(TaskModel task) async {
    DocumentReference docRef = await _db.collection('tasks').add(task.toMap());
    return docRef.id;
  }
  
  Future<void> updateTaskDetails(String taskId, Map<String, dynamic> data) async {
    await _db.collection('tasks').doc(taskId).update(data);
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> updateTaskAttachments(String taskId, List<AttachmentModel> attachments) async {
    await _db.collection('tasks').doc(taskId).update({
      'attachments': attachments.map((a) => a.toMap()).toList(),
    });
  }

  Stream<List<TaskModel>> streamTasks(String projectId) {
    return _db.collection('tasks')
        .where('project_id', isEqualTo: projectId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Lấy tất cả task liên quan đến User (dựa trên danh sách Project IDs)
  Stream<List<TaskModel>> streamAllUserTasks(List<String> projectIds) {
    if (projectIds.isEmpty) return Stream.value([]);
    
    return _db.collection('tasks')
        .where('project_id', whereIn: projectIds)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _db.collection('tasks').doc(taskId).update({
      'status': status.toString().split('.').last
    });
  }

  // --- COMMENT OPERATIONS ---
  Future<void> addComment(String taskId, CommentModel comment) async {
    await _db.collection('tasks').doc(taskId).collection('comments').add(comment.toMap());
  }

  Stream<List<CommentModel>> streamComments(String taskId) {
    return _db.collection('tasks').doc(taskId).collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => CommentModel.fromMap(doc.data(), doc.id)).toList());
  }
}
