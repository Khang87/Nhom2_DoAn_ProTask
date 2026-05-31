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
              onTap: () => _showLanguagePicker(context)),
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
              onTap: () => _showLogoutDialog(context, isDark, authProvider)),

          _buildSectionTitle(localeProvider.getText('about')),
          _buildVersionRow(isDark, localeProvider),
        ],
      ),
    );
  }

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
                    onTap: () {
                      localeProvider.setLocale(langCode);
                      Navigator.pop(context);
                    },
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

  void _showLogoutDialog(BuildContext context, bool isDark, AuthProvider auth) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
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