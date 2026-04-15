import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Thêm Firebase Auth
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import '../provider/auth_provider.dart';
import '../database/database_helper.dart';
import 'register_screen.dart';
import 'forgotpass_screen.dart';

// --- Widget vẽ Logo ma trận 3x3 (Giữ nguyên) ---
class ProTaskLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double gridSpacing = 28.0;
    const double iconSize = 20.0;
    final Color greyColor = Colors.grey.withOpacity(0.4);
    final Color cyanColor = Colors.cyanAccent.shade400;
    final matrix = [[0, 0, 0], [1, 0, 0], [1, 1, 0]];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final double x = c * gridSpacing + iconSize / 2;
        final double y = r * gridSpacing + iconSize / 2;
        final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(matrix[r][c] == 0 ? Icons.stop.codePoint : Icons.add.codePoint),
          style: TextStyle(fontSize: iconSize, fontFamily: Icons.add.fontFamily, color: matrix[r][c] == 0 ? greyColor : cyanColor, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  bool _isLoading = false; // Biến trạng thái khi đang đợi Firebase

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // --- Hàm xử lý Đăng nhập với Firebase & SQLite ---
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passController.text.trim();

    setState(() => _isLoading = true);

    try {
      // 🔥 1. Login Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 🔥 2. Gọi Provider (nó tự lo SQLite)
        await Provider.of<AuthProvider>(context, listen: false)
            .loginWithFirebase(firebaseUser);

        // 🔥 3. Chuyển màn
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Sai tài khoản hoặc mật khẩu!");
    } catch (e) {
      _showSnackBar("Lỗi hệ thống!");
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Modal chọn ngôn ngữ (Giữ nguyên logic của Hùng) ---
  void _showLanguagePicker(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
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
                      color: isSelected ? (isDark ? Colors.white10 : Colors.blue.withOpacity(0.1)) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      child: Row(
                        children: [
                          Opacity(opacity: isSelected ? 1.0 : 0.0, child: const Icon(Icons.check, color: Colors.blue, size: 20)),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(langData['native']!, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                              Text(langData['vietnamese']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Center(
              child: TextButton.icon(
                onPressed: () => _showLanguagePicker(context),
                icon: const Icon(Icons.language, size: 20, color: Colors.grey),
                label: Row(children: [Text(localeProvider.currentLanguageNativeName, style: const TextStyle(color: Colors.grey)), const Icon(Icons.arrow_drop_down, color: Colors.grey)]),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(width: 84, height: 84, child: CustomPaint(painter: ProTaskLogoPainter())),
            const SizedBox(height: 30),
            Text("ProTask App", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 50),

            // Input Email
            TextField(
              controller: _emailController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: localeProvider.getText('email_hint'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),

            // Input Password
            TextField(
              controller: _passController,
              obscureText: _isObscure,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: localeProvider.getText('password'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscure = !_isObscure)),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF91B9FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(localeProvider.getText('login'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF91B9FF), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(localeProvider.getText('register'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
              child: Text(localeProvider.getText('forgot_password'), style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}