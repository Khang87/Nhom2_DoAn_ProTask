import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import '../provider/auth_provider.dart';
import 'my_profile_screen.dart';
import 'notification_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text("Cài đặt", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("CHUNG"),
          _buildSettingTile(Icons.language, "Ngôn ngữ", isDark, subtitle: localeProvider.currentLanguageNativeName, onTap: () {}),
          _buildSettingTile(Icons.dark_mode, "Chủ đề", isDark, subtitle: isDark ? "Tối" : "Sáng", onTap: () => themeProvider.toggleTheme()),

          _buildSectionTitle("TÀI KHOẢN"),
          _buildSettingTile(Icons.account_circle_outlined, "Hồ sơ", isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfileScreen()));
          }),
          _buildSettingTile(Icons.notifications_none, "Thông báo", isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
          }),
          _buildSettingTile(Icons.lock_outline, "Đổi mật khẩu", isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
          }),
          _buildSettingTile(Icons.logout, "Đăng xuất", isDark, titleColor: Colors.redAccent,
              onTap: () => _showLogoutDialog(context, isDark, authProvider)),

          _buildSectionTitle("GIỚI THIỆU"),
          _buildVersionRow(isDark),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Đăng xuất khỏi ProTask App?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ bỏ", style: TextStyle(color: Colors.blue))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); auth.logout(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF91B9FF), shape: StadiumBorder()),
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 20, top: 25, bottom: 10),
    child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
  );

  Widget _buildSettingTile(IconData icon, String title, bool isDark, {String? subtitle, VoidCallback? onTap, Color? titleColor}) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? (isDark ? Colors.white70 : Colors.black54)),
        title: Text(title, style: TextStyle(color: titleColor ?? (isDark ? Colors.white : Colors.black))),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVersionRow(bool isDark) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Phiên bản", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      const Text("2.9.0 (39)", style: TextStyle(color: Colors.grey)),
    ]),
  );
}