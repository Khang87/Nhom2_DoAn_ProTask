class UserModel {
  final String? id;
  final String username;
  final String email;
  final String uid;
  final String? phone;
  final String? photoUrl;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.uid,
    this.phone,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString(),
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
    );
  }
}
