import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
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
import 'kanban_screen.dart';
import '../provider/locale_provider.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  VoidCallback? _projectListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userModel != null) {
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        projectProvider.listenToProjects(auth.userModel!.uid);

        _projectListener = () {
          if (!mounted) return;
          final pIds = projectProvider.projects.map((p) => p.projectId).toList();
          if (pIds.isNotEmpty) {
            Provider.of<TaskProvider>(context, listen: false).listenToAllTasks(pIds);
          }
        };
        projectProvider.addListener(_projectListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_projectListener != null) {
      try {
        Provider.of<ProjectProvider>(context, listen: false).removeListener(_projectListener!);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const HomeTab(),
      const TimelineScreen(),
      const CalendarScreen(),
      const ChartsScreen(),
      const ProfileScreen(),
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: _buildBottomNav(isDark),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: AppShadows.bottomBar(isDark),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(0, Icons.grid_view_rounded, Icons.grid_view_outlined, localeProvider.getText('home_projects'), isDark)),
              Expanded(child: _buildNavItem(1, Icons.timeline_rounded, Icons.timeline_outlined, localeProvider.getText('home_timeline'), isDark)),
              Expanded(child: _buildNavItem(2, Icons.calendar_month_rounded, Icons.calendar_month_outlined, localeProvider.getText('home_calendar'), isDark)),
              Expanded(child: _buildNavItem(3, Icons.bar_chart_rounded, Icons.bar_chart_outlined, localeProvider.getText('home_reports'), isDark)),
              Expanded(child: _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, localeProvider.getText('home_me'), isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HOME TAB ────────────────────────────────────────────────────────────────

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String username = authProvider.userModel?.displayName ?? "User";

    final doneTasks = taskProvider.tasks.where((t) => t.status == TaskStatus.done).length;
    final totalTasks = taskProvider.tasks.length;
    final inProgressTasks = taskProvider.tasks.where((t) => t.status == TaskStatus.in_progress).length;

    return CustomScrollView(
      slivers: [
        // ── App Bar ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(localeProvider),
                          style: AppTextStyles.caption(isDark),
                        ),
                        const SizedBox(height: 2),
                        Text(username, style: AppTextStyles.heading2(isDark)),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showJoinProjectDialog(context, isDark, authProvider.userModel?.uid ?? ''),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showCreateProjectDialog(context, isDark, authProvider.userModel?.uid ?? '', localeProvider),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              gradient: AppGradients.brand,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppShadows.glow(AppColors.primary),
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(child: _buildStatCard(localeProvider.getText('home_total_tasks'), totalTasks.toString(), Icons.task_alt_rounded, AppColors.primary, isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(localeProvider.getText('home_in_progress'), inProgressTasks.toString(), Icons.pending_actions_rounded, AppColors.statusInProgress, isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(localeProvider.getText('home_completed'), doneTasks.toString(), Icons.check_circle_outline_rounded, AppColors.statusDone, isDark)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Projects Section ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localeProvider.getText('home_my_projects'), style: AppTextStyles.heading3(isDark)),
                Text(
                  localeProvider.getText('home_projects_count', params: {'count': projectProvider.projects.length.toString()}),
                  style: AppTextStyles.caption(isDark),
                ),
              ],
            ),
          ),
        ),

        if (projectProvider.isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
            ),
          )
        else if (projectProvider.projects.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyProjects(isDark, context, authProvider.userModel?.uid ?? '', localeProvider))
        else
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: projectProvider.projects.length,
                itemBuilder: (context, index) {
                  final project = projectProvider.projects[index];
                  return _buildProjectCard(context, project, isDark, authProvider.userModel?.uid ?? '', taskProvider, localeProvider);
                },
              ),
            ),
          ),

        // ── Upcoming Deadlines ─────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text(localeProvider.getText('home_upcoming_deadlines'), style: AppTextStyles.heading3(isDark)),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final upcomingTasks = _getUpcomingTasks(taskProvider.tasks);
                if (upcomingTasks.isEmpty) {
                  return _buildEmptyDeadlines(isDark, localeProvider);
                }
                if (index >= upcomingTasks.length) return null;
                return _buildDeadlineItem(upcomingTasks[index], isDark, localeProvider);
              },
              childCount: () {
                final count = _getUpcomingTasks(taskProvider.tasks).length;
                return count == 0 ? 1 : count;
              }(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  String _getGreeting(LocaleProvider localeProvider) {
    final hour = DateTime.now().hour;
    if (hour < 12) return localeProvider.getText('home_greeting_morning');
    if (hour < 17) return localeProvider.getText('home_greeting_afternoon');
    return localeProvider.getText('home_greeting_evening');
  }

  List<TaskModel> _getUpcomingTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    final upcoming = tasks.where((t) {
      if (t.dueDate == null || t.status == TaskStatus.done) return false;
      final diff = t.dueDate!.difference(now).inDays;
      return diff >= 0 && diff <= 7;
    }).toList();
    upcoming.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return upcoming.take(5).toList();
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.plusJakartaSans(
            fontSize: 22, fontWeight: FontWeight.w800, color: color,
          )),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, bool isDark, String currentUserId, TaskProvider taskProvider, LocaleProvider localeProvider) {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final role = projectProvider.getUserRole(project.projectId, currentUserId);
    final canManage = role == 'owner' || role == 'manager';

    // Count tasks for this project
    final projectTasks = taskProvider.tasks.where((t) => t.projectId == project.projectId).toList();
    final doneTasks = projectTasks.where((t) => t.status == TaskStatus.done).length;
    final progress = projectTasks.isEmpty ? 0.0 : doneTasks / projectTasks.length;

    final List<LinearGradient> gradients = [
      AppGradients.cardPurple,
      AppGradients.cardCyan,
      AppGradients.cardEmerald,
      AppGradients.cardAmber,
    ];
    final gradient = gradients[project.title.hashCode.abs() % gradients.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KanbanScreen(projectId: project.projectId)),
      ),
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.folder_rounded, color: Colors.white, size: 18),
                ),
                if (canManage)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localeProvider.getText('home_permission_denied'))),
                      );
                    },
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              project.title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              project.description,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localeProvider.getText('home_task_count', params: {'done': doneTasks.toString(), 'total': projectTasks.length.toString()}),
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  "${(progress * 100).round()}%",
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProjects(bool isDark, BuildContext context, String userId, LocaleProvider localeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showCreateProjectDialog(context, isDark, userId, localeProvider),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                localeProvider.getText('home_create_first_project'),
                style: AppTextStyles.heading3(isDark),
              ),
              const SizedBox(height: 6),
              Text(
                localeProvider.getText('home_create_project_desc'),
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineItem(TaskModel task, bool isDark, LocaleProvider localeProvider) {
    final now = DateTime.now();
    final daysLeft = task.dueDate!.difference(now).inDays;
    final bool isUrgent = daysLeft <= 1;
    final Color accentColor = isUrgent ? AppColors.priorityHigh : AppColors.statusInProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isUrgent ? AppColors.priorityHigh.withOpacity(0.3) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTextStyles.bodyMedium(isDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                      style: AppTextStyles.caption(isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              daysLeft == 0 ? localeProvider.getText('home_today') : localeProvider.getText('home_days_left', params: {'days': daysLeft.toString()}),
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeadlines(bool isDark, LocaleProvider localeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available_rounded, size: 40, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 10),
            Text(localeProvider.getText('home_no_deadlines'), style: AppTextStyles.body(isDark)),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, bool isDark, String userId, LocaleProvider localeProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final emailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 0, right: 0,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.brand,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(localeProvider.getText('home_create_project_title'), style: AppTextStyles.heading3(isDark)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                style: AppTextStyles.body(isDark),
                decoration: InputDecoration(
                  labelText: localeProvider.getText('home_project_name'),
                  prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: AppTextStyles.body(isDark),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: localeProvider.getText('home_project_desc'),
                  prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailsController,
                style: AppTextStyles.body(isDark),
                decoration: InputDecoration(
                  labelText: localeProvider.getText('home_project_members'),
                  prefixIcon: const Icon(Icons.group_add_outlined, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: localeProvider.getText('home_btn_create_project'),
                  icon: Icons.rocket_launch_rounded,
                  onTap: () {
                    if (titleController.text.isNotEmpty) {
                      List<String> emails = emailsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      Provider.of<ProjectProvider>(context, listen: false)
                          .createProject(titleController.text, descController.text, userId, emails);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinProjectDialog(BuildContext context, bool isDark, String userId) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text("Tham gia dự án", style: AppTextStyles.heading3(isDark)),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: codeController,
                  style: AppTextStyles.body(isDark),
                  decoration: const InputDecoration(
                    labelText: "Nhập mã dự án",
                    prefixIcon: Icon(Icons.vpn_key_outlined, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: "Tham gia ngay",
                    icon: Icons.check_circle_outline_rounded,
                    onTap: () {
                      if (codeController.text.isNotEmpty) {
                        Provider.of<ProjectProvider>(context, listen: false)
                            .joinProjectByCode(codeController.text.trim(), userId);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Tham gia thành công! Vui lòng chờ tải dữ liệu."),
                            backgroundColor: AppColors.statusDone,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
