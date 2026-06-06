import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../model/task_model.dart';
import '../provider/task_provider.dart';
import '../service/storage_service.dart';
import '../provider/auth_provider.dart';
import '../provider/project_provider.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';
import '../service/google_calendar_service.dart';
import '../service/notification_service.dart';
import '../service/firestore_service.dart';
import '../model/user_model.dart';
import 'project_chat_screen.dart';

class KanbanScreen extends StatefulWidget {
  final String projectId;
  const KanbanScreen({super.key, required this.projectId});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  TaskPriority? _selectedPriority;
  late TabController _tabController;

  final List<_KanbanColumn> _columns = const [
    _KanbanColumn("Cần làm", TaskStatus.todo, AppColors.statusTodo, Icons.radio_button_unchecked_rounded),
    _KanbanColumn("Đang làm", TaskStatus.in_progress, AppColors.statusInProgress, Icons.pending_rounded),
    _KanbanColumn("Review", TaskStatus.review, AppColors.statusReview, Icons.rate_review_rounded),
    _KanbanColumn("Hoàn thành", TaskStatus.done, AppColors.statusDone, Icons.check_circle_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _columns.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).listenToTasks(widget.projectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // Search + Filter
          _buildSearchAndFilter(isDark),

          // Tab Bar
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              indicator: UnderlineTabIndicator(
                borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              tabAlignment: TabAlignment.start,
              tabs: _columns.map((col) {
                return Consumer<TaskProvider>(
                  builder: (context, tp, _) {
                    final count = tp.getTasksByStatus(col.status).length;
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(col.icon, size: 14, color: col.color),
                          const SizedBox(width: 6),
                          Text(col.title),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: col.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              count.toString(),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: col.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Kanban Boards via TabView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _columns.map((col) {
                return _buildColumnContent(context, col, isDark, auth.userModel?.uid ?? '');
              }).toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context, isDark, auth.userModel?.uid ?? ''),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Task mới", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bảng Kanban", style: AppTextStyles.heading3(isDark)),
          Text("Kéo thả để cập nhật trạng thái", style: AppTextStyles.caption(isDark)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 22),
          onPressed: () => _showInviteMemberDialog(context, isDark),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  final project = Provider.of<ProjectProvider>(context, listen: false).projects.firstWhere((p) => p.projectId == widget.projectId);
                  return ProjectChatScreen(
                    projectId: widget.projectId,
                    projectName: project.title,
                  );
                },
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_rounded, size: 18, color: AppColors.primary),
          ),
        ),
        Consumer<TaskProvider>(
          builder: (ctx, tp, _) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: StatusBadge(
                label: "${tp.tasks.length} tasks",
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Consumer<ProjectProvider>(
          builder: (context, projectProvider, child) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final role = projectProvider.getUserRole(widget.projectId, auth.userModel?.uid ?? '');
            if (role == 'owner') {
              return PopupMenuButton<String>(
                icon: Icon(Icons.settings_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                onSelected: (val) async {
                  if (val == 'delete_project') {
                    final project = projectProvider.projects.firstWhere((p) => p.projectId == widget.projectId);
                    final memberIds = project.members.map((m) => m.userId).toList();
                    await projectProvider.deleteProject(widget.projectId, memberIds);
                    if (context.mounted) Navigator.pop(context);
                  } else if (val == 'manage_members') {
                    _showManageMembersDialog(context, isDark);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'manage_members',
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text("Quản lý thành viên", style: AppTextStyles.body(isDark)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete_project',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppColors.priorityHigh, size: 20),
                        const SizedBox(width: 8),
                        Text("Xóa dự án", style: AppTextStyles.body(isDark).copyWith(color: AppColors.priorityHigh)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(width: 8);
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          // Search
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: AppTextStyles.body(isDark),
            decoration: InputDecoration(
              hintText: "Tìm kiếm task...",
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => _searchQuery = ""),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.primary),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          // Priority filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip("Tất cả", null, Icons.all_inclusive_rounded, isDark),
                _buildChip("Cao", TaskPriority.high, Icons.keyboard_arrow_up_rounded, isDark),
                _buildChip("Trung bình", TaskPriority.medium, Icons.remove_rounded, isDark),
                _buildChip("Thấp", TaskPriority.low, Icons.keyboard_arrow_down_rounded, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildChip(String label, TaskPriority? priority, IconData icon, bool isDark) {
    final isSelected = _selectedPriority == priority;
    final color = priority == null
        ? AppColors.primary
        : (priority == TaskPriority.high
            ? AppColors.priorityHigh
            : priority == TaskPriority.medium
                ? AppColors.priorityMedium
                : AppColors.priorityLow);

    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : (isDark ? AppColors.darkCard : const Color(0xFFF3F2FF)),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnContent(BuildContext context, _KanbanColumn column, bool isDark, String currentUserId) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.getTasksByStatus(column.status).where((task) {
          final matchSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchPriority = _selectedPriority == null || task.priority == _selectedPriority;
          return matchSearch && matchPriority;
        }).toList();

        return DragTarget<TaskModel>(
          onWillAccept: (data) => data?.status != column.status,
          onAccept: (data) => taskProvider.updateStatus(data.taskId, column.status),
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: candidateData.isNotEmpty
                  ? column.color.withOpacity(0.05)
                  : Colors.transparent,
              child: tasks.isEmpty
                  ? _buildEmptyColumn(column, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _KanbanTaskCard(task: tasks[index], columnColor: column.color);
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyColumn(_KanbanColumn column, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: column.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(column.icon, color: column.color, size: 28),
          ),
          const SizedBox(height: 16),
          Text("Trống", style: AppTextStyles.heading3(isDark)),
          const SizedBox(height: 6),
          Text(
            "Kéo task vào đây hoặc\ntạo task mới",
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(isDark),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, bool isDark, String userId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? selectedDate;
    List<File> selectedFiles = [];
    List<String> selectedAssignees = [];

    final project = Provider.of<ProjectProvider>(context, listen: false)
        .projects.firstWhere((p) => p.projectId == widget.projectId);
    final memberIds = project.members.map((m) => m.userId).toList();
    final usersFuture = FirestoreService().getUsersByIds(memberIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        TaskPriority selectedPriority = TaskPriority.medium;
        return StatefulBuilder(
          builder: (ctx, setSheet) => Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text("Tạo Task mới", style: AppTextStyles.heading2(isDark)),
                    const SizedBox(height: 20),

                    TextField(
                      controller: titleCtrl,
                      style: AppTextStyles.body(isDark),
                      decoration: const InputDecoration(
                        labelText: "Tiêu đề task",
                        prefixIcon: Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: descCtrl,
                      style: AppTextStyles.body(isDark),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Mô tả (tùy chọn)",
                        prefixIcon: Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text("Độ ưu tiên", style: AppTextStyles.captionBold(isDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _priorityChipStateful(selectedPriority, TaskPriority.low, "Thấp", AppColors.priorityLow,
                            () => setSheet(() => selectedPriority = TaskPriority.low)),
                        const SizedBox(width: 8),
                        _priorityChipStateful(selectedPriority, TaskPriority.medium, "Trung", AppColors.priorityMedium,
                            () => setSheet(() => selectedPriority = TaskPriority.medium)),
                        const SizedBox(width: 8),
                        _priorityChipStateful(selectedPriority, TaskPriority.high, "Cao", AppColors.priorityHigh,
                            () => setSheet(() => selectedPriority = TaskPriority.high)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text("Thời hạn (Deadline)", style: AppTextStyles.captionBold(isDark)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheet(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null ? "Chọn ngày hết hạn" : DateFormat('dd/MM/yyyy').format(selectedDate!),
                              style: AppTextStyles.body(isDark).copyWith(
                                color: selectedDate == null ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight) : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text("Người phụ trách", style: AppTextStyles.captionBold(isDark)),
                    const SizedBox(height: 8),
                    FutureBuilder<List<UserModel>>(
                      future: usersFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator(color: AppColors.primary);
                        final users = snapshot.data!;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: users.map((u) {
                            final isSelected = selectedAssignees.contains(u.uid);
                            return FilterChip(
                              label: Text(u.displayName, style: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                              checkmarkColor: Colors.white,
                              onSelected: (val) {
                                setSheet(() {
                                  if (val) {
                                    selectedAssignees.add(u.uid);
                                  } else {
                                    selectedAssignees.remove(u.uid);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    Text("Tệp đính kèm", style: AppTextStyles.captionBold(isDark)),
                    const SizedBox(height: 8),
                    if (selectedFiles.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          children: selectedFiles.map((f) {
                            String fName = f.path.split(Platform.pathSeparator).last;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fName,
                                      style: AppTextStyles.bodyMedium(isDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setSheet(() => selectedFiles.remove(f));
                                    },
                                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.priorityHigh),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        List<File> picked = await StorageService().pickFiles();
                        if (picked.isNotEmpty) {
                          setSheet(() {
                            selectedFiles.addAll(picked);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Tải tệp đính kèm",
                              style: AppTextStyles.bodyMedium(isDark).copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: "Tạo Task",
                        icon: Icons.add_task_rounded,
                        onTap: () {
                          if (titleCtrl.text.isNotEmpty) {
                            final newTask = TaskModel(
                              taskId: '',
                              projectId: widget.projectId,
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              status: TaskStatus.todo,
                              priority: selectedPriority,
                              assignees: selectedAssignees,
                              attachments: [],
                              dueDate: selectedDate,
                              createdAt: DateTime.now(),
                            );
                            Provider.of<TaskProvider>(context, listen: false).createTask(
                              newTask,
                              localFiles: selectedFiles,
                            );
                            
                            // Trigger Sync & Notifications
                            if (selectedDate != null) {
                              GoogleCalendarService().syncTaskToCalendar(newTask);
                            }
                            NotificationService.showNotification(
                              title: "Đã phân công Task mới",
                              body: "Bạn được giao task: ${newTask.title}",
                            );

                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  void _showInviteMemberDialog(BuildContext context, bool isDark) {
    final emailCtrl = TextEditingController();
    String selectedRole = 'member';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text("Thêm thành viên", style: AppTextStyles.heading3(isDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cách 1: Nhập Email", style: AppTextStyles.captionBold(isDark)),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                style: AppTextStyles.body(isDark),
                decoration: InputDecoration(
                  labelText: "Email thành viên",
                  labelStyle: AppTextStyles.caption(isDark),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Vai trò",
                  labelStyle: AppTextStyles.caption(isDark),
                  prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                ),
                dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                items: [
                  DropdownMenuItem(value: 'manager', child: Text("Quản lý (Manager)", style: AppTextStyles.body(isDark))),
                  DropdownMenuItem(value: 'member', child: Text("Thành viên (Member)", style: AppTextStyles.body(isDark))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
              const SizedBox(height: 24),
              Text("Cách 2: Gửi Link / Mã dự án", style: AppTextStyles.captionBold(isDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.projectId,
                        style: AppTextStyles.body(isDark).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Normally copy to clipboard here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đã sao chép mã dự án!"), backgroundColor: AppColors.primary),
                        );
                      },
                      child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Người được mời sẽ tự động trở thành Thành viên (Member) sau khi nhập mã này.",
                style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Hủy", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              onPressed: () {
                if (emailCtrl.text.isNotEmpty) {
                  Provider.of<ProjectProvider>(context, listen: false)
                      .inviteMember(widget.projectId, emailCtrl.text.trim(), selectedRole);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã gửi lời mời đến ${emailCtrl.text.trim()}", style: GoogleFonts.inter()),
                      backgroundColor: AppColors.statusDone,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Text("Mời", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageMembersDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Quản lý thành viên", style: AppTextStyles.heading3(isDark)),
                const SizedBox(height: 16),
                Consumer<ProjectProvider>(
                  builder: (context, projectProvider, child) {
                    final project = projectProvider.projects.firstWhere((p) => p.projectId == widget.projectId);
                    final memberIds = project.members.map((m) => m.userId).toList();
                    return FutureBuilder<List<UserModel>>(
                      future: FirestoreService().getUsersByIds(memberIds),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final users = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final member = project.members.firstWhere((m) => m.userId == user.uid);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                child: Text(user.displayName.isNotEmpty ? user.displayName[0] : 'U', style: TextStyle(color: AppColors.primary)),
                              ),
                              title: Text(user.displayName, style: AppTextStyles.body(isDark)),
                              subtitle: Text(member.role, style: AppTextStyles.caption(isDark)),
                              trailing: member.role == 'owner' ? null : PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                onSelected: (val) {
                                  if (val == 'remove') {
                                    projectProvider.removeMember(widget.projectId, user.uid);
                                  } else if (val == 'promote') {
                                    projectProvider.updateMemberRole(widget.projectId, user.uid, 'manager');
                                  } else if (val == 'demote') {
                                    projectProvider.updateMemberRole(widget.projectId, user.uid, 'member');
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (member.role == 'member') const PopupMenuItem(value: 'promote', child: Text("Nâng làm Manager")),
                                  if (member.role == 'manager') const PopupMenuItem(value: 'demote', child: Text("Hạ xuống Member")),
                                  const PopupMenuItem(value: 'remove', child: Text("Xóa khỏi dự án", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _priorityChipStateful(TaskPriority current, TaskPriority value, String label, Color color, VoidCallback onTap) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? color : AppColors.darkBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.flag_rounded, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? color : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── KANBAN COLUMN CONFIG ─────────────────────────────────────────────────────

class _KanbanColumn {
  final String title;
  final TaskStatus status;
  final Color color;
  final IconData icon;

  const _KanbanColumn(this.title, this.status, this.color, this.icon);
}

// ─── TASK CARD ────────────────────────────────────────────────────────────────

class _KanbanTaskCard extends StatelessWidget {
  final TaskModel task;
  final Color columnColor;

  _KanbanTaskCard({super.key, required this.task, required this.columnColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LongPressDraggable<TaskModel>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.glow(AppColors.primary),
            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
          ),
          child: Text(task.title, style: AppTextStyles.bodyMedium(isDark)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: _buildCard(context, isDark)),
      child: _buildCard(context, isDark),
    );
  }

  Widget _buildCard(BuildContext context, bool isDark) {
    final priorityColor = task.priority == TaskPriority.high
        ? AppColors.priorityHigh
        : task.priority == TaskPriority.medium
            ? AppColors.priorityMedium
            : AppColors.priorityLow;

    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.done;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isOverdue
                ? AppColors.priorityHigh.withOpacity(0.4)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isOverdue ? 1.5 : 1,
          ),
          boxShadow: AppShadows.card(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored indicator
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: columnColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority + date row
                  Row(
                    children: [
                      StatusBadge(
                        label: task.priority == TaskPriority.high
                            ? "Cao"
                            : task.priority == TaskPriority.medium
                                ? "Trung bình"
                                : "Thấp",
                        color: priorityColor,
                        small: true,
                      ),
                      const Spacer(),
                      if (task.dueDate != null) ...[
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isOverdue ? AppColors.priorityHigh : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM').format(task.dueDate!),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOverdue ? AppColors.priorityHigh : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    task.title,
                    style: AppTextStyles.bodyMedium(isDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: AppTextStyles.caption(isDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Bottom row
                  Row(
                    children: [
                      if (isOverdue) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.priorityHigh.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            "Quá hạn",
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.priorityHigh),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (task.assignees.isNotEmpty)
                        Row(
                          children: List.generate(
                            task.assignees.length.clamp(0, 3),
                            (i) => Container(
                              width: 24, height: 24,
                              margin: EdgeInsets.only(left: i > 0 ? -6 : 0),
                              decoration: BoxDecoration(
                                gradient: AppGradients.brand,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(Icons.person_rounded, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for let-chaining (utility)
extension Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
