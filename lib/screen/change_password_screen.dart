import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _handleChangePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu mới không khớp")),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải có ít nhất 6 ký tự")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().changePassword(
            _oldPasswordController.text,
            _newPasswordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll('Exception: ', '')}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: Text("Đổi mật khẩu", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mật khẩu mới của bạn phải khác mật khẩu trước đó.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildPasswordField(
              label: "Mật khẩu hiện tại",
              controller: _oldPasswordController,
              isVisible: _isOldPasswordVisible,
              onToggle: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: "Mật khẩu mới",
              controller: _newPasswordController,
              isVisible: _isNewPasswordVisible,
              onToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: "Xác nhận mật khẩu mới",
              controller: _confirmPasswordController,
              isVisible: _isConfirmPasswordVisible,
              onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              isDark: isDark,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF91B9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Cập nhật mật khẩu",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: onToggle,
            ),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
          ),
        ),
      ],
    );
  }
}
