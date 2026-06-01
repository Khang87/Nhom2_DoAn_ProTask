import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  bool _isObscure = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(username);
        await firebaseUser.sendEmailVerification();

        _showSnackBar("✅ Đã gửi mail xác thực tới $email");

        await FirebaseAuth.instance.signOut();
        if (mounted) Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Đã có lỗi xảy ra";
      if (e.code == 'weak-password') {
        message = "Mật khẩu quá yếu (tối thiểu 6 ký tự)";
      } else if (e.code == 'email-already-in-use') {
        message = "Email này đã được đăng ký";
      } else if (e.code == 'invalid-email') {
        message = "Định dạng email không hợp lệ";
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Lỗi hệ thống, vui lòng thử lại");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: AppGradients.brand,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tạo tài khoản", style: AppTextStyles.heading2(isDark)),
                            Text(
                              "Bắt đầu hành trình của bạn 🚀",
                              style: AppTextStyles.caption(isDark),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Full Name
                    _buildFieldLabel("Họ và tên", isDark),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: AppTextStyles.body(isDark),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: localeProvider.getText('full_name'),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email
                    _buildFieldLabel("Email", isDark),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.body(isDark),
                      decoration: InputDecoration(
                        labelText: localeProvider.getText('email_hint'),
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password
                    _buildFieldLabel("Mật khẩu", isDark),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passController,
                      obscureText: _isObscure,
                      style: AppTextStyles.body(isDark),
                      decoration: InputDecoration(
                        labelText: localeProvider.getText('password'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _isObscure = !_isObscure),
                          child: Icon(
                            _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password hint
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          "Mật khẩu tối thiểu 6 ký tự",
                          style: AppTextStyles.caption(isDark).copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: localeProvider.getText('register'),
                        isLoading: _isLoading,
                        onTap: _handleRegister,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Đã có tài khoản? ",
                          style: AppTextStyles.body(isDark).copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Đăng nhập",
                            style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}