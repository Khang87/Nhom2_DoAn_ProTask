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

  String? _verificationId;

  // 🔥 Gửi mã OTP
  Future<void> sendOTP(String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Tự động xác thực nếu Firebase nhận diện được (Android)
        await _auth.signInWithCredential(credential);
        _checkCurrentUser();
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e.message ?? "Lỗi xác thực số điện thoại");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // 🔥 Xác thực mã OTP
  Future<void> verifyOTP(String smsCode) async {
    if (_verificationId == null) throw Exception("Chưa gửi mã OTP");
    
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    UserCredential result = await _auth.signInWithCredential(credential);
    if (result.user != null) {
      await loginWithFirebase(result.user!);
    }
  }

  // 🔥 Thay đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception("Người dùng chưa đăng nhập");

    // Firebase yêu cầu re-authenticate trước khi đổi mật khẩu
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // 🔥 Logout sạch
  Future<void> logout() async {
    await _auth.signOut();
    // Không nên xóa sạch users nếu muốn giữ lịch sử, nhưng ở đây theo yêu cầu clean
    // await DatabaseHelper().clearAllUsers(); 
    _currentUser = null;
    notifyListeners();
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