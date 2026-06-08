import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../provider/task_provider.dart';
import '../model/task_model.dart';
import '../provider/locale_provider.dart';
import '../provider/project_provider.dart';
import '../provider/auth_provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _filter = 'all'; // 'all', 'upcoming', 'done'
  String _selectedStream = 'managed'; // 'managed', 'participated'
  String _selectedProjectId = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskProvider>().fetchAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final projectProvider = context.watch<ProjectProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.userModel?.uid ?? '';

    final projects = projectProvider.projects;

    // Phân loại dự án
    final myManagedProjects = projects.where((p) {
      final role = projectProvider.getUserRole(p.projectId, userId);
      return role == 'owner' || role == 'manager';
    }).toList();

    final myParticipatedProjects = projects.where((p) {
      final role = projectProvider.getUserRole(p.projectId, userId);
      return role != 'owner' && role != 'manager';
    }).toList();

    final currentList = _selectedStream == 'managed' ? myManagedProjects : myParticipatedProjects;

    // Ensure selected project is valid
    if (_selectedProjectId != 'all' && !currentList.any((p) => p.projectId == _selectedProjectId)) {
      // Must use addPostFrameCallback if we are changing state, but actually we can just reset it locally or schedule
      // Better to just not reset state during build, but fallback locally:
      // We will do a local variable fallback if needed, but it's simpler to schedule it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedProjectId = 'all');
      });
    }

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  const SizedBox(height: 16),
                  Text("Đang tải...", style: AppTextStyles.caption(isDark)),
                ],
              ),
            );
          }

          var tasks = List<TaskModel>.from(taskProvider.tasks);

          // 1. Lọc theo luồng và dự án
          String effectiveProjectId = _selectedProjectId;
          if (effectiveProjectId != 'all' && !currentList.any((p) => p.projectId == effectiveProjectId)) {
            effectiveProjectId = 'all';
          }

          if (effectiveProjectId != 'all') {
            tasks = tasks.where((t) => t.projectId == effectiveProjectId).toList();
          } else {
            final validProjectIds = currentList.map((p) => p.projectId).toSet();
            tasks = tasks.where((t) => validProjectIds.contains(t.projectId)).toList();
          }

          // 2. Lọc theo trạng thái
          if (_filter == 'upcoming') {
            tasks = tasks.where((t) => t.status != TaskStatus.done).toList();
          } else if (_filter == 'done') {
            tasks = tasks.where((t) => t.status == TaskStatus.done).toList();
          }

          // 3. Sắp xếp theo ngày hạn
          tasks.sort((a, b) {
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: AppGradients.cardCyan,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.timeline_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(localeProvider.getText("timeline_title"), style: AppTextStyles.heading2(isDark)),
                                Text(localeProvider.getText("timeline_task_count", params: {"count": tasks.length.toString()}), style: AppTextStyles.caption(isDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 2 Luồng (Tabs)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedStream = 'managed';
                                  _selectedProjectId = 'all';
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedStream == 'managed' 
                                        ? (isDark ? AppColors.darkCard : Colors.white) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    boxShadow: _selectedStream == 'managed' ? AppShadows.card(isDark) : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(localeProvider.getText("timeline_tab_managed"), style: AppTextStyles.bodyMedium(isDark).copyWith(
                                    color: _selectedStream == 'managed' ? AppColors.primary : Colors.grey,
                                    fontWeight: _selectedStream == 'managed' ? FontWeight.w700 : FontWeight.w500,
                                  )),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedStream = 'participated';
                                  _selectedProjectId = 'all';
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedStream == 'participated' 
                                        ? (isDark ? AppColors.darkCard : Colors.white) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    boxShadow: _selectedStream == 'participated' ? AppShadows.card(isDark) : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(localeProvider.getText("timeline_tab_participated"), style: AppTextStyles.bodyMedium(isDark).copyWith(
                                    color: _selectedStream == 'participated' ? AppColors.primary : Colors.grey,
                                    fontWeight: _selectedStream == 'participated' ? FontWeight.w700 : FontWeight.w500,
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chọn Dự Án
                      if (currentList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBg : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: effectiveProjectId,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                              items: [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text(localeProvider.getText("timeline_all_projects"), style: AppTextStyles.bodyMedium(isDark)),
                                ),
                                ...currentList.map((p) => DropdownMenuItem(
                                  value: p.projectId,
                                  child: Text(p.title, style: AppTextStyles.bodyMedium(isDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ))
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedProjectId = val);
                              },
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip(localeProvider.getText("timeline_filter_all"), 'all', isDark),
                            const SizedBox(width: 8),
                            _filterChip(localeProvider.getText("timeline_filter_upcoming"), 'upcoming', isDark),
                            const SizedBox(width: 8),
                            _filterChip(localeProvider.getText("timeline_filter_done"), 'done', isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timeline list
              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: _buildEmpty(isDark),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        final bool isDone = task.status == TaskStatus.done;
                        final bool isFirst = index == 0;
                        final bool isLast = index == tasks.length - 1;

                        return TimelineTile(
                          alignment: TimelineAlign.start,
                          isFirst: isFirst,
                          isLast: isLast,
                          indicatorStyle: IndicatorStyle(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(4),
                            indicator: _buildIndicator(task, isDone),
                          ),
                          beforeLineStyle: LineStyle(
                            color: isDone
                                ? AppColors.statusDone
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            thickness: 2,
                          ),
                          afterLineStyle: LineStyle(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            thickness: 2,
                          ),
                          endChild: Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 20),
                            child: _buildTimelineCard(task, isDone, isDark),
                          ),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIndicator(TaskModel task, bool isDone) {
    Color color;
    IconData icon;

    if (isDone) {
      color = AppColors.statusDone;
      icon = Icons.check_rounded;
    } else if (task.status == TaskStatus.in_progress) {
      color = AppColors.statusInProgress;
      icon = Icons.play_arrow_rounded;
    } else if (task.status == TaskStatus.review) {
      color = AppColors.statusReview;
      icon = Icons.rate_review_rounded;
    } else {
      color = AppColors.statusTodo;
      icon = Icons.circle_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildTimelineCard(TaskModel task, bool isDone, bool isDark) {
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !isDone;
    final priorityColor = task.priority == TaskPriority.high
        ? AppColors.priorityHigh
        : task.priority == TaskPriority.medium
            ? AppColors.priorityMedium
            : AppColors.priorityLow;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isOverdue
              ? AppColors.priorityHigh.withOpacity(0.4)
              : isDone
                  ? AppColors.statusDone.withOpacity(0.3)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: task.priority == TaskPriority.high ? "Cao" : task.priority == TaskPriority.medium ? "Trung bình" : "Thấp",
                color: priorityColor,
                small: true,
              ),
              const SizedBox(width: 8),
              if (isOverdue)
                StatusBadge(label: "Quá hạn", color: AppColors.priorityHigh, small: true),
              const Spacer(),
              if (task.dueDate != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(task.dueDate!),
                  style: AppTextStyles.caption(isDark).copyWith(
                    color: isOverdue ? AppColors.priorityHigh : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: AppTextStyles.bodyMedium(isDark).copyWith(
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight) : null,
            ),
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
          Row(
            children: [
              _statusChip(context, task.status, isDark),
              const Spacer(),
              if (task.assignees.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.group_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      "${task.assignees.length} người",
                      style: AppTextStyles.caption(isDark),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, TaskStatus status, bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    Color color;
    String label;
    switch (status) {
      case TaskStatus.todo:
        color = AppColors.statusTodo;
        label = localeProvider.getText("kanban_status_todo");
        break;
      case TaskStatus.in_progress:
        color = AppColors.statusInProgress;
        label = localeProvider.getText("kanban_status_in_progress");
        break;
      case TaskStatus.review:
        color = AppColors.statusReview;
        label = localeProvider.getText("kanban_status_review");
        break;
      case TaskStatus.done:
        color = AppColors.statusDone;
        label = localeProvider.getText("timeline_filter_done");
        break;
    }
    return StatusBadge(label: label, color: color, small: true);
  }

  Widget _filterChip(String label, String value, bool isDark) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.brand : null,
          color: isSelected ? null : (isDark ? AppColors.darkCard : const Color(0xFFF3F2FF)),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timeline_rounded, color: AppColors.secondary, size: 36),
          ),
          const SizedBox(height: 20),
          Text("Không có công việc nào", style: AppTextStyles.heading3(isDark)),
          const SizedBox(height: 8),
          Text("Tạo task trong Kanban để xem timeline", style: AppTextStyles.caption(isDark), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
