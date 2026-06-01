import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
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
  bool _isOldVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnack("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack("Mật khẩu mới không khớp");
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnack("Mật khẩu phải có ít nhất 6 ký tự");
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
          SnackBar(
            content: Text("✅ Đổi mật khẩu thành công!", style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            backgroundColor: AppColors.statusDone,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack("Lỗi: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: AppGradients.cardPurple,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.glow(const Color(0xFF7C3AED)),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),

              Text("Đổi mật khẩu", style: AppTextStyles.heading1(isDark)),
              const SizedBox(height: 8),
              Text(
                "Mật khẩu mới phải khác mật khẩu trước đó và có tối thiểu 6 ký tự.",
                style: AppTextStyles.body(isDark).copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 36),

              // Old password
              _buildLabel("Mật khẩu hiện tại", isDark),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _oldPasswordController,
                hint: "Nhập mật khẩu hiện tại",
                isVisible: _isOldVisible,
                onToggle: () => setState(() => _isOldVisible = !_isOldVisible),
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // New password
              _buildLabel("Mật khẩu mới", isDark),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _newPasswordController,
                hint: "Nhập mật khẩu mới",
                isVisible: _isNewVisible,
                onToggle: () => setState(() => _isNewVisible = !_isNewVisible),
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // Confirm password
              _buildLabel("Xác nhận mật khẩu mới", isDark),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: "Nhập lại mật khẩu mới",
                isVisible: _isConfirmVisible,
                onToggle: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                isDark: isDark,
              ),

              // Password strength hint
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: AppColors.statusDone),
                  const SizedBox(width: 5),
                  Text(
                    "Dùng ký tự chữ + số + ký tự đặc biệt để mật khẩu mạnh hơn",
                    style: AppTextStyles.caption(isDark).copyWith(color: AppColors.statusDone),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: "Cập nhật mật khẩu",
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isLoading,
                  onTap: _handleChangePassword,
                  gradient: AppGradients.cardPurple,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTextStyles.body(isDark),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            size: 20,
          ),
        ),
      ),
    );
  }
}
