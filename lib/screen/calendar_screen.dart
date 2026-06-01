import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../provider/task_provider.dart';
import '../model/task_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() => context.read<TaskProvider>().fetchAllTasks());
  }

  List<TaskModel> _getTasksForDay(List<TaskModel> tasks, DateTime day) {
    return tasks.where((task) =>
      task.dueDate != null && isSameDay(task.dueDate, day)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;
          final selectedTasks = tasks.where((task) =>
            task.dueDate != null && isSameDay(task.dueDate, _selectedDay)
          ).toList();

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
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: AppGradients.cardEmerald,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lịch Công việc", style: AppTextStyles.heading2(isDark)),
                          Text("Deadline theo ngày", style: AppTextStyles.caption(isDark)),
                        ],
                      ),
                      const Spacer(),
                      // Format toggle
                      GestureDetector(
                        onTap: () => setState(() {
                          _calendarFormat = _calendarFormat == CalendarFormat.month
                              ? CalendarFormat.week
                              : CalendarFormat.month;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            _calendarFormat == CalendarFormat.month ? "Tuần" : "Tháng",
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Calendar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    boxShadow: AppShadows.card(isDark),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() => _calendarFormat = format);
                      }
                    },
                    eventLoader: (day) => _getTasksForDay(tasks, day),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        final hasTasks = _getTasksForDay(tasks, day).isNotEmpty;
                        if (hasTasks) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: AppTextStyles.body(isDark).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      todayTextStyle: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.w700,
                      ),
                      selectedDecoration: const BoxDecoration(
                        gradient: AppGradients.brand,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w700,
                      ),
                      defaultTextStyle: AppTextStyles.body(isDark),
                      weekendTextStyle: AppTextStyles.body(isDark).copyWith(color: AppColors.priorityHigh),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.heading3(isDark),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: AppTextStyles.captionBold(isDark),
                      weekendStyle: AppTextStyles.captionBold(isDark).copyWith(color: AppColors.priorityHigh),
                    ),
                  ),
                ),
              ),

              // Selected day tasks
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 18,
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDay != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDay!)
                            : "Hôm nay",
                        style: AppTextStyles.heading3(isDark),
                      ),
                      const SizedBox(width: 10),
                      if (selectedTasks.isNotEmpty)
                        StatusBadge(
                          label: "${selectedTasks.length} task",
                          color: AppColors.primary,
                          small: true,
                        ),
                    ],
                  ),
                ),
              ),

              // Task List
              selectedTasks.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyDay(isDark))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildTaskItem(selectedTasks[index], isDark),
                          childCount: selectedTasks.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyDay(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available_rounded, size: 48,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text("Không có task nào trong ngày này", style: AppTextStyles.body(isDark)),
            const SizedBox(height: 4),
            Text("Ngày tự do! 🎉", style: AppTextStyles.caption(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, bool isDark) {
    final isDone = task.status == TaskStatus.done;
    final priorityColor = task.priority == TaskPriority.high
        ? AppColors.priorityHigh
        : task.priority == TaskPriority.medium
            ? AppColors.priorityMedium
            : AppColors.priorityLow;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDone
              ? AppColors.statusDone.withOpacity(0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: (isDone ? AppColors.statusDone : priorityColor).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isDone ? AppColors.statusDone : priorityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyMedium(isDark).copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      label: task.priority == TaskPriority.high ? "Cao" : task.priority == TaskPriority.medium ? "Trung bình" : "Thấp",
                      color: priorityColor,
                      small: true,
                    ),
                    const SizedBox(width: 8),
                    if (task.dueDate != null) ...[
                      Icon(Icons.access_time_rounded, size: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(task.dueDate!),
                        style: AppTextStyles.caption(isDark),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle_rounded, color: AppColors.statusDone, size: 20),
        ],
      ),
    );
  }
}
