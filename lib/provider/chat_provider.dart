import 'package:flutter/material.dart';
import '../model/message_model.dart';
import '../service/firestore_service.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void listenToMessages(String projectId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamChatMessages(projectId).listen((messageList) {
      _messages = messageList.map((m) => MessageModel.fromMap(m, m['id'])).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(MessageModel message) async {
    await _firestoreService.sendChatMessage(message.projectId, message.toMap());
  }
}
