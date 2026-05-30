import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOTPSent = false;
  bool _isLoading = false;

  Future<void> _handleSendOTP() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập số điện thoại")));
      return;
    }
    
    // Đảm bảo định dạng +84 cho Việt Nam nếu người dùng nhập 0
    if (phone.startsWith('0')) {
      phone = '+84${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+84$phone';
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendOTP(
        phone,
        onCodeSent: (id) {
          setState(() {
            _isOTPSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP đã được gửi!")));
        },
        onVerificationFailed: (err) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().verifyOTP(_otpController.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP không đúng hoặc đã hết hạn!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: Text(_isOTPSent ? "Xác thực OTP" : "Quên mật khẩu", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isOTPSent ? "Nhập mã xác thực" : "Nhập số điện thoại",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Text(
              _isOTPSent ? "Mã xác thực gồm 6 chữ số đã được gửi tới số điện thoại của bạn." : "Chúng tôi sẽ gửi mã OTP để xác thực tài khoản của bạn.",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (!_isOTPSent) ...[
              _buildInputField(
                label: "Số điện thoại",
                controller: _phoneController,
                hint: "0901234567",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _buildButton("Gửi mã OTP", _handleSendOTP),
            ] else ...[
              _buildInputField(
                label: "Mã OTP",
                controller: _otpController,
                hint: "123456",
                icon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _buildButton("Xác nhận", _handleVerifyOTP),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isOTPSent = false),
                  child: const Text("Đổi số điện thoại", style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF91B9FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
