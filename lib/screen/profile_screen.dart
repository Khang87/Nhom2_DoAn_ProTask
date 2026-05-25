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
        title: Text(localeProvider.getText('settings'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle(localeProvider.getText('general')),
          _buildSettingTile(Icons.language, localeProvider.getText('language'), isDark, 
              subtitle: localeProvider.currentLanguageNativeName, 
              onTap: () => _showLanguageDialog(context, isDark, localeProvider)),
          _buildSettingTile(Icons.dark_mode, localeProvider.getText('theme'), isDark, 
              subtitle: isDark ? localeProvider.getText('dark') : localeProvider.getText('light'), 
              onTap: () => themeProvider.toggleTheme()),

          _buildSectionTitle(localeProvider.getText('account')),
          _buildSettingTile(Icons.account_circle_outlined, localeProvider.getText('profile'), isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfileScreen()));
          }),
          _buildSettingTile(Icons.notifications_none, localeProvider.getText('notifications'), isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
          }),
          _buildSettingTile(Icons.lock_outline, localeProvider.getText('change_password'), isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
          }),
          _buildSettingTile(Icons.logout, localeProvider.getText('logout'), isDark, titleColor: Colors.redAccent,
              onTap: () => _showLogoutDialog(context, isDark, authProvider, localeProvider)),

          _buildSectionTitle(localeProvider.getText('about')),
          _buildVersionRow(isDark, localeProvider),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isDark, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(localeProvider.getText('select_language'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: localeProvider.supportedLocales.length,
            itemBuilder: (context, index) {
              String langCode = localeProvider.supportedLocales.keys.elementAt(index);
              String nativeName = localeProvider.supportedLocales[langCode]!['native']!;
              bool isSelected = localeProvider.locale.languageCode == langCode;

              return ListTile(
                title: Text(nativeName, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  localeProvider.setLocale(langCode);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark, AuthProvider auth, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(localeProvider.getText('logout_confirm'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(localeProvider.getText('cancel'), style: const TextStyle(color: Colors.blue))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); auth.logout(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF91B9FF), shape: const StadiumBorder()),
            child: Text(localeProvider.getText('logout'), style: const TextStyle(color: Colors.black)),
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

  Widget _buildVersionRow(bool isDark, LocaleProvider localeProvider) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(localeProvider.getText('version'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      const Text("2.9.0 (39)", style: TextStyle(color: Colors.grey)),
    ]),
  );
}