import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
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
    final user = authProvider.userModel;
    final username = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.darkBg, AppColors.darkCard.withOpacity(0.8)]
                        : [AppColors.lightBg, AppColors.primary.withOpacity(0.05)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfileScreen())),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.brand,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : "U",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 40, fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 4,
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.brand,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? AppColors.darkBg : Colors.white, width: 3),
                                ),
                                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        username,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email_rounded, size: 14, color: isDark ? Colors.white70 : AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              user?.email ?? "",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Settings Blocks
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // System Settings Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppShadows.card(isDark),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          _buildSectionLabel("HỆ THỐNG", isDark),
                          _buildTile(
                            context,
                            icon: Icons.language_rounded,
                            color: AppColors.secondary,
                            label: "Ngôn ngữ",
                            subtitle: localeProvider.currentLanguageNativeName,
                            isDark: isDark,
                            onTap: () => _showLanguageDialog(context, isDark, localeProvider),
                          ),
                          _buildDivider(isDark),
                          _buildTile(
                            context,
                            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: const Color(0xFFF59E0B),
                            label: "Giao diện",
                            subtitle: isDark ? "Tối" : "Sáng",
                            isDark: isDark,
                            onTap: () => themeProvider.toggleTheme(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Settings Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppShadows.card(isDark),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          _buildSectionLabel("BẢO MẬT & THÔNG BÁO", isDark),
                          _buildTile(
                            context,
                            icon: Icons.notifications_rounded,
                            color: const Color(0xFFEF4444),
                            label: "Thông báo",
                            isDark: isDark,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                          ),
                          _buildDivider(isDark),
                          _buildTile(
                            context,
                            icon: Icons.lock_rounded,
                            color: const Color(0xFF8B5CF6),
                            label: "Đổi mật khẩu",
                            isDark: isDark,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                          ),
                          _buildDivider(isDark),
                          _buildTile(
                            context,
                            icon: Icons.logout_rounded,
                            color: const Color(0xFFEF4444),
                            label: "Đăng xuất",
                            isDark: isDark,
                            isDestructive: true,
                            onTap: () => _showLogoutDialog(context, isDark, authProvider),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Version Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppGradients.brand,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "ProTask v1.0.0",
                      style: AppTextStyles.captionBold(isDark).copyWith(fontSize: 14),
                    ),
                    Text(
                      "Elevating Productivity",
                      style: AppTextStyles.caption(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 64,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required bool isDark,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption(isDark).copyWith(fontSize: 13))
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        size: 22,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Text("Đăng xuất?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          "Bạn có chắc muốn đăng xuất khỏi ProTask không?",
          style: AppTextStyles.body(isDark),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Huỷ", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); auth.logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text("Đăng xuất", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isDark, LocaleProvider localeProvider) {
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
          mainAxisSize: MainAxisSize.min,
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
                  final entry = localeProvider.supportedLocales.entries.elementAt(index);
                  final isSelected = localeProvider.locale.languageCode == entry.key;
                  return InkWell(
                    onTap: () {
                      localeProvider.setLocale(entry.key);
                      Navigator.pop(context);
                    },
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
                              Text(entry.value['native']!, style: AppTextStyles.bodyMedium(isDark)),
                              Text(entry.value['vietnamese']!, style: AppTextStyles.caption(isDark)),
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
}