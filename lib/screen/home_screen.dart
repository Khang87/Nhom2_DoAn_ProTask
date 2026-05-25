import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/theme_provider.dart';
import '../provider/locale_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final localeProvider = Provider.of<LocaleProvider>(context);

    final List<Widget> _pages = [
      const HomeTab(),
      Center(child: Text(localeProvider.getText('task_detail_screen'))),
      Center(child: Text(localeProvider.getText('group_notifications'))),
      const ProfileScreen(),
    ];

    // Cố định textScaleFactor để không bị nhảy chữ to khi máy ảo bật Font to
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: const Color(0xFF91B9FF),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.grid_view_outlined), label: localeProvider.getText('projects')),
            BottomNavigationBarItem(icon: const Icon(Icons.assignment_outlined), label: localeProvider.getText('tasks')),
            BottomNavigationBarItem(icon: const Icon(Icons.notifications_outlined), label: localeProvider.getText('notifications_tab')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: localeProvider.getText('me')),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String username = authProvider.currentUser?['username'] ?? "Bùi Quốc Hùng";

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          floating: true,
          pinned: true,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          title: Text(
            localeProvider.getText('app_projects_title'),
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => _showCreateProjectDialog(context, isDark, localeProvider),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${localeProvider.getText('welcome')}, $username 👋", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                Text(localeProvider.getText('running_projects'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Dự án cuộn ngang có link nộp bài
                SizedBox(
                  height: 190,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildProjectCard("App Coffee Shop", "Hùng (L), Huy, Khang", 0.7, Colors.orange, isDark, localeProvider),
                      _buildProjectCard("Website Đồ án", "Hùng (L), Nam", 0.3, Colors.blue, isDark, localeProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Text(localeProvider.getText('your_tasks'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Danh sách Task (SỬA LỖI CHỮ TO Ở ĐÂY)
                _buildTaskItem("Thiết kế UI Login", "Đồ án Mobile", localeProvider.getText('today'), true, isDark),
                _buildTaskItem("Fix lỗi Database", "Website", localeProvider.getText('overdue'), false, isDark, isOverdue: true),
                _buildTaskItem("Làm slide báo cáo", "Nhóm 1", "2 ${localeProvider.getText('days_left')}", false, isDark),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProjectCard(String name, String members, double progress, Color color, bool isDark, LocaleProvider localeProvider) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.folder_shared, color: color),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(members, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          // Nút link giả lập
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link, size: 14, color: color),
                const SizedBox(width: 5),
                Text(localeProvider.getText('link_task'), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String category, String time, bool isDone, bool isDark, {bool isOverdue = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? Colors.green : (isOverdue ? Colors.red : Colors.grey)),
          const SizedBox(width: 15),

          // Dùng Expanded để chữ không được đẩy văng các widget khác
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // Cố định cỡ chữ
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(color: isOverdue ? Colors.red : Colors.grey, fontSize: 11, fontWeight: isOverdue ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, bool isDark, LocaleProvider localeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localeProvider.getText('create_new_project'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: localeProvider.getText('project_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            TextField(decoration: InputDecoration(labelText: localeProvider.getText('link_task_url'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
              child: Text(localeProvider.getText('create_now'), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}