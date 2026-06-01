import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isEmailEnabled = true;
  bool _isPushEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          "Cài đặt Thông báo",
          style: AppTextStyles.heading2(isDark),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hệ thống thông báo",
              style: AppTextStyles.heading3(isDark).copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "Quản lý cách bạn nhận thông tin cập nhật về dự án, công việc và lịch trình.",
              style: AppTextStyles.body(isDark).copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            
            AppCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.email_rounded,
                    color: AppColors.secondary,
                    title: "Email",
                    subtitle: "Nhận cập nhật qua hộp thư điện tử",
                    value: _isEmailEnabled,
                    onChanged: (val) => setState(() => _isEmailEnabled = val),
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 64, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  _buildSwitchTile(
                    icon: Icons.notifications_active_rounded,
                    color: const Color(0xFFEF4444),
                    title: "Thông báo đẩy (Push)",
                    subtitle: "Thông báo trực tiếp trên thiết bị",
                    value: _isPushEnabled,
                    onChanged: (val) => setState(() => _isPushEnabled = val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption(isDark).copyWith(fontSize: 13),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.5),
        inactiveThumbColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }
}