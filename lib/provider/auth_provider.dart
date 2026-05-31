import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  Map<String, dynamic>? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkCurrentUser();
  }

  // 🔥 Tự động login khi mở app
  // 🔥 Tự động login khi mở app
  Future<void> _checkCurrentUser() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      try {
        // Làm mới dữ liệu từ Firebase Server
        await firebaseUser.reload();
        firebaseUser = _auth.currentUser;

        // KIỂM TRA EMAIL TRƯỚC KHI DÙNG DẤU !
        if (firebaseUser?.email != null) {
          // 🔥 Sync vào SQLite
          await DatabaseHelper().insertOrUpdateUser(
            email: firebaseUser!.email!,
            uid: firebaseUser.uid,
            phone: firebaseUser.phoneNumber,
          );

          // 🔥 Lấy user local
          _currentUser = await DatabaseHelper().getUserByEmail(firebaseUser.email!);
        }
      } catch (e) {
        print("Lỗi reload user: $e");
        // Nếu lỗi do user bị xóa trên server, có thể cho logout
        // await logout();
      }
    } else {
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }
  // 🔥 Gọi sau khi login thành công
  Future<void> loginWithFirebase(User firebaseUser) async {
    // Trước khi lưu, đảm bảo lấy dữ liệu mới nhất
    await firebaseUser.reload();

    await DatabaseHelper().insertOrUpdateUser(
      email: firebaseUser.email!,
      uid: firebaseUser.uid,
      phone: firebaseUser.phoneNumber, // Đồng bộ SĐT khi login
    );

    _currentUser = await DatabaseHelper().getUserByEmail(firebaseUser.email!);
    notifyListeners();
  }

  // 🔥 Logout sạch
  Future<void> logout() async {
    await _auth.signOut();

    await DatabaseHelper().clearAllUsers(); // optional

    _currentUser = null;
    notifyListeners();
  }

  // 🔥 Quên mật khẩu
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserPhone(String newPhone) async {
    if (_currentUser != null) {
      // 1. Tạo một bản sao mới từ Map cũ để có thể chỉnh sửa
      final updatedUser = Map<String, dynamic>.from(_currentUser!);

      // 2. Cập nhật số điện thoại vào bản sao này
      updatedUser['phone'] = newPhone;

      // 3. Gán bản sao đã sửa vào _currentUser
      _currentUser = updatedUser;

      // 4. Thông báo cho giao diện (ProfileScreen) vẽ lại ngay lập tức
      notifyListeners();

      // 5. Lưu xuống SQLite để lần sau mở máy vẫn còn
      await DatabaseHelper().updateUserField(
          _currentUser!['email'], 'phone', newPhone);

      print("Đã cập nhật số điện thoại thành công vào RAM và DB!");
    }
  }
}