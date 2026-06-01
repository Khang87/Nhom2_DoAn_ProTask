import 'package:flutter/material.dart';
import '../model/comment_model.dart';
import '../service/firestore_service.dart';

class CommentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<CommentModel> _comments = [];
  bool _isLoading = false;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;

  void listenToComments(String taskId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamComments(taskId).listen((commentList) {
      _comments = commentList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addComment(String taskId, CommentModel comment) async {
    await _firestoreService.addComment(taskId, comment);
  }
}
