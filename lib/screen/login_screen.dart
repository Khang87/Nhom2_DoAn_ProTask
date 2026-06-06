import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import '../provider/auth_provider.dart';
import 'register_screen.dart';
import 'forgotpass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final loginInput = _emailController.text.trim();
    final password = _passController.text.trim();
    
    if (loginInput.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin");
      return;
    }
    
    setState(() => _isLoading = true);
    
    String emailToLogin = loginInput;

    try {
      // 1. Kiểm tra nếu nhập vào là số điện thoại (bắt đầu bằng 0 hoặc +)
      if (RegExp(r'^[0-9+]+$').hasMatch(loginInput)) {
        String phoneSearch = loginInput.replaceAll(RegExp(r'[^\d+]'), '');
        if (phoneSearch.startsWith('+840')) {
          phoneSearch = '+84${phoneSearch.substring(4)}';
        } else if (phoneSearch.startsWith('840')) {
          phoneSearch = '+84${phoneSearch.substring(3)}';
        } else if (phoneSearch.startsWith('84') && !phoneSearch.startsWith('+84')) {
          phoneSearch = '+84${phoneSearch.substring(2)}';
        } else if (phoneSearch.startsWith('0')) {
          phoneSearch = '+84${phoneSearch.substring(1)}';
        } else if (!phoneSearch.startsWith('+')) {
          phoneSearch = '+84$phoneSearch';
        }

        // Tìm email tương ứng với sdt này trong Firestore
        var query = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phoneSearch)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          emailToLogin = query.docs.first.data()['email'] ?? loginInput;
        } else {
          _showSnackBar("Số điện thoại chưa được liên kết!");
          setState(() => _isLoading = false);
          return;
        }
      }

      // 2. Tiến hành đăng nhập bằng Email/Password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailToLogin, password: password);
          
      final firebaseUser = userCredential.user;
      if (firebaseUser != null && mounted) {
        await Provider.of<AuthProvider>(context, listen: false).loginWithFirebase(firebaseUser);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException {
      if (mounted) _showSnackBar("Sai tài khoản hoặc mật khẩu!");
    } catch (e) {
      if (mounted) _showSnackBar("Lỗi hệ thống!");
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

  void _showLanguagePicker(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: 16),
            Text("Chọn ngôn ngữ", style: AppTextStyles.heading3(isDark)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: localeProvider.supportedLocales.length,
                itemBuilder: (context, index) {
                  final langCode = localeProvider.supportedLocales.keys.elementAt(index);
                  final langData = localeProvider.supportedLocales[langCode]!;
                  final bool isSelected = langCode == localeProvider.locale.languageCode;
                  return InkWell(
                    onTap: () { localeProvider.setLocale(langCode); Navigator.pop(context); },
                    child: Container(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(langData['native']!, style: AppTextStyles.bodyMedium(isDark)),
                              Text(langData['vietnamese']!, style: AppTextStyles.caption(isDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // ── Top Bar ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showLanguagePicker(context),
                            icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                            label: Text(
                              localeProvider.currentLanguageNativeName,
                              style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => themeProvider.toggleTheme(),
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
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Logo & Branding ──────────────────────────
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: AppGradients.brand,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.glow(AppColors.primary),
                      ),
                      child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text("ProTask", style: AppTextStyles.heading1(isDark)),
                    const SizedBox(height: 8),
                    Text(
                      "Quản lý dự án nhóm thông minh",
                      style: AppTextStyles.body(isDark).copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Form ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTextStyles.body(isDark),
                            decoration: InputDecoration(
                              labelText: localeProvider.getText('email_hint'),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
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

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                localeProvider.getText('forgot_password'),
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              label: localeProvider.getText('login'),
                              isLoading: _isLoading,
                              onTap: _handleLogin,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: Text(localeProvider.getText('register')),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Footer ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        "ProTask v1.0.0 · HUIT 2025",
                        style: AppTextStyles.caption(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}