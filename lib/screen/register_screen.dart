import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Cần thêm gói này
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscure = true;
  bool _isLoading = false;

  // 1. Tạo Controller để lấy dữ liệu
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // 2. Hàm xử lý Đăng ký & Xác thực Email
  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final username = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 1. Tạo tài khoản Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 🔥 2. Cập nhật tên user lên Firebase
        await firebaseUser.updateDisplayName(username);

        // 🔥 3. Gửi email xác thực
        await firebaseUser.sendEmailVerification();

        _showSnackBar("Đã gửi mail xác thực tới $email");

        // 🔥 4. Logout luôn (bắt user login lại sau khi verify)
        await FirebaseAuth.instance.signOut();

        if (mounted) Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      String message = "Đã có lỗi xảy ra";

      if (e.code == 'weak-password') {
        message = "Mật khẩu quá yếu";
      } else if (e.code == 'email-already-in-use') {
        message = "Email đã tồn tại";
      } else if (e.code == 'invalid-email') {
        message = "Email không hợp lệ";
      }

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Lỗi hệ thống");
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: 84,
              height: 84,
              child: CustomPaint(painter: ProTaskLogoPainter()),
            ),
            const SizedBox(height: 30),
            Text(
              "Palexy Store Optimizer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            Text(localeProvider.getText('register_title'), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            // Input Họ tên
            _buildInput(_nameController, localeProvider.getText('full_name'), isDark, false),
            const SizedBox(height: 20),

            // Input Email
            _buildInput(_emailController, localeProvider.getText('email_hint'), isDark, false),
            const SizedBox(height: 20),

            // Input Mật khẩu
            _buildInput(_passController, localeProvider.getText('password'), isDark, true),

            const SizedBox(height: 40),

            // Nút Đăng ký
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF91B9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                  localeProvider.getText('register'),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text("Phiên bản 2.9.0 (39)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, bool isDark, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass ? _isObscure : false,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: isPass ? IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ) : null,
      ),
    );
  }
}