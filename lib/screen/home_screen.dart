import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/theme_provider.dart';
import '../provider/project_provider.dart';
import '../provider/task_provider.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';
import 'profile_screen.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';
import 'charts_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProjectProvider>().fetchProjects();
      context.read<TaskProvider>().fetchAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final List<Widget> _pages = [
      const HomeTab(),
      const TimelineScreen(),
      const CalendarScreen(),
      const ChartsScreen(),
      const ProfileScreen(),
    ];

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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: "Dự án"),
            BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Timeline"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Lịch"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Báo cáo"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tôi"),
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
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String username = authProvider.currentUser?['username'] ?? "User";

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          floating: true,
          pinned: true,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          title: Text(
            "ProTask Projects",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => _showCreateProjectDialog(context, isDark),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chào mừng, $username 👋", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                const Text("Dự án đang chạy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                projectProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : projectProvider.projects.isEmpty
                    ? const Text("Chưa có dự án nào")
                    : SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: projectProvider.projects.length,
                          itemBuilder: (context, index) {
                            final project = projectProvider.projects[index];
                            return _buildProjectCard(context, project, isDark);
                          },
                        ),
                      ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Nhiệm vụ của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_task, color: Colors.blue),
                      onPressed: () => _showAddTaskDialog(context, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskProvider.tasks.isEmpty
                    ? const Text("Chưa có nhiệm vụ nào")
                    : Column(
                        children: taskProvider.tasks.take(5).map((task) {
                          return _buildTaskItem(context, task, isDark);
                        }).toList(),
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, bool isDark) {
    final color = Color(project.color);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    // Tính toán progress thực tế từ Firestore tasks
    final projectTasks = taskProvider.tasks.where((t) => t.projectId == project.id).toList();
    double realProgress = 0.0;
    if (projectTasks.isNotEmpty) {
      int doneCount = projectTasks.where((t) => t.isDone).length;
      realProgress = doneCount / projectTasks.length;
    }

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
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(project.members, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          if (project.link != null && project.link!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link, size: 14, color: color),
                  const SizedBox(width: 5),
                  Text("Link nộp task", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: realProgress, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, bool isDark) {
    final isOverdue = !task.isDone && task.deadline.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(task.isDone ? Icons.check_circle : Icons.radio_button_unchecked, 
                 color: task.isDone ? Colors.green : (isOverdue ? Colors.red : Colors.grey)),
            onPressed: () {
              final updatedTask = TaskModel(
                id: task.id,
                projectId: task.projectId,
                title: task.title,
                description: task.description,
                assigneeId: task.assigneeId,
                status: task.isDone ? 'Todo' : 'Done',
                deadline: task.deadline,
                isDone: !task.isDone,
              );
              Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask).then((_) {
                Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
              });
            },
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(DateFormat('dd/MM HH:mm').format(task.deadline), 
                     style: TextStyle(color: isOverdue ? Colors.red : Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id).then((_) {
                Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
              });
            },
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final membersController = TextEditingController();
    final linkController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
            const Text("Tạo dự án mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên dự án", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            TextField(controller: membersController, decoration: InputDecoration(labelText: "Thành viên (Hùng, Huy...)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            TextField(controller: linkController, decoration: InputDecoration(labelText: "Link nộp bài (URL)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newProject = ProjectModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: "",
                    ownerId: authProvider.currentUser?['uid'] ?? "unknown",
                    members: membersController.text,
                    progress: 0.0,
                    deadline: DateTime.now().add(const Duration(days: 7)),
                    color: Colors.blue.value,
                    link: linkController.text,
                  );
                  Provider.of<ProjectProvider>(context, listen: false).addProject(newProject);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
              child: const Text("Tạo ngay", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? selectedProjectId = projectProvider.projects.isNotEmpty ? projectProvider.projects.first.id : null;

    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng tạo dự án trước!")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Thêm nhiệm vụ mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedProjectId,
                decoration: const InputDecoration(labelText: "Chọn dự án"),
                items: projectProvider.projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) => setModalState(() => selectedProjectId = val),
              ),
              const SizedBox(height: 15),
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Tiêu đề nhiệm vụ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && selectedProjectId != null) {
                    final newTask = TaskModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: selectedProjectId!,
                      title: titleController.text,
                      description: "",
                      assigneeId: authProvider.currentUser?['uid'] ?? "unknown",
                      status: 'Todo',
                      deadline: DateTime.now().add(const Duration(days: 1)),
                      isDone: false,
                    );
                    Provider.of<TaskProvider>(context, listen: false).addTask(newTask).then((_) {
                      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Thêm nhiệm vụ", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}