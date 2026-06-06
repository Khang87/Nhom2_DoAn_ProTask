import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phone;
  final List<String> joinedProjects;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.phone = '',
    required this.joinedProjects,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      phone: map['phone'] ?? '',
      joinedProjects: List<String>.from(map['joined_projects'] ?? []),
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone': phone,
      'joined_projects': joinedProjects,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
