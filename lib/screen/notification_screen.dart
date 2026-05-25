import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/locale_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 1. Khai báo các biến lưu trạng thái công tắc
  bool _isEmailEnabled = true;
  bool _isPushEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Màu chữ linh hoạt theo theme
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            localeProvider.getText('notification_title'),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  localeProvider.getText('notification_schedule_update'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor
                  )
              ),
              const SizedBox(height: 20),

              // 2. Truyền biến và hàm setState vào _tile
              _tile(
                Icons.email_outlined,
                localeProvider.getText('email_notification'),
                localeProvider.getText('email_notification_sub'),
                _isEmailEnabled,
                    (bool value) {
                  setState(() {
                    _isEmailEnabled = value;
                  });
                  // Hùng có thể thêm logic lưu vào SharedPreferences hoặc DB ở đây
                  print("Email notification: $value");
                },
                textColor,
              ),

              _tile(
                Icons.notifications_none,
                localeProvider.getText('push_notification'),
                localeProvider.getText('push_notification_sub'),
                _isPushEnabled,
                    (bool value) {
                  setState(() {
                    _isPushEnabled = value;
                  });
                  print("Push notification: $value");
                },
                textColor,
              ),
            ]
        ),
      ),
    );
  }

  // Cập nhật hàm _tile để nhận callback onChanged và màu sắc
  Widget _tile(
      IconData icon,
      String title,
      String sub,
      bool val,
      ValueChanged<bool> onChanged,
      Color textColor,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero, // Bỏ padding mặc định để căn lề đẹp hơn
      leading: Icon(icon, color: Colors.grey),
      title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
      ),
      subtitle: Text(
          sub,
          style: const TextStyle(color: Colors.grey, fontSize: 12)
      ),
      trailing: Switch(
        value: val,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}