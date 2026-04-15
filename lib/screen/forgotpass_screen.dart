import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import '../provider/auth_provider.dart'; // Import AuthProvider để gọi logic Firebase

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 1. Tạo controller để lấy Email người dùng nhập
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // 2. Hàm xử lý gửi Email khôi phục
  Future<void> _handleResetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Vui lòng nhập Email của bạn");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gọi hàm gửi mail đổi mật khẩu đã viết trong AuthProvider
      await authProvider.sendPasswordReset(email);

      _showSnackBar("Link đặt lại mật khẩu đã được gửi vào Email của bạn!");

      // Đợi người dùng đọc thông báo rồi quay lại màn Login
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _showSnackBar("Email không tồn tại hoặc đã xảy ra lỗi!");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black,
              size: 20
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            Text(
              localeProvider.getText('forgot_password_title'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              localeProvider.getText('forgot_password_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // TextField gắn controller
            TextField(
              controller: _emailController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: localeProvider.getText('email_hint'),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF91B9FF), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF91B9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                  localeProvider.getText('continue_btn'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Text(
              "Phiên bản 2.9.0 (39)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}