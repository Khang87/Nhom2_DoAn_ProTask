import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../provider/task_provider.dart';
import '../model/task_model.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
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
                              gradient: AppGradients.brand,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Báo cáo & Phân tích", style: AppTextStyles.heading2(isDark)),
                              Text("Tổng quan hiệu suất dự án", style: AppTextStyles.caption(isDark)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: _buildEmpty(isDark),
                )
              else ...[
                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildSummaryCards(tasks, isDark),
                  ),
                ),

                // Pie Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildPieSection(tasks, isDark),
                  ),
                ),

                // Bar Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: _buildBarSection(tasks, isDark),
                  ),
                ),
              ],
            ],
          );
        },
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 20),
          Text("Chưa có dữ liệu thống kê", style: AppTextStyles.heading3(isDark)),
          const SizedBox(height: 8),
          Text("Tạo và hoàn thành các task để xem báo cáo", style: AppTextStyles.caption(isDark), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<TaskModel> tasks, bool isDark) {
    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.in_progress).length;
    final overdue = tasks.where((t) {
      return t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.done;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tổng quan", style: AppTextStyles.heading3(isDark)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _summaryTile("Tổng", total.toString(), AppColors.primary, Icons.assignment_rounded, isDark)),
            const SizedBox(width: 10),
            Expanded(child: _summaryTile("Xong", done.toString(), AppColors.statusDone, Icons.check_circle_rounded, isDark)),
            const SizedBox(width: 10),
            Expanded(child: _summaryTile("Đang làm", inProgress.toString(), AppColors.statusInProgress, Icons.pending_rounded, isDark)),
            const SizedBox(width: 10),
            Expanded(child: _summaryTile("Quá hạn", overdue.toString(), AppColors.priorityHigh, Icons.warning_rounded, isDark)),
          ],
        ),

        // Progress bar
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tỉ lệ hoàn thành", style: AppTextStyles.bodyMedium(isDark)),
                  Text(
                    "${total > 0 ? (done / total * 100).round() : 0}%",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.statusDone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: total > 0 ? (done / total) * _anim.value : 0,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusDone),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(String label, String value, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildPieSection(List<TaskModel> tasks, bool isDark) {
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.in_progress).length;
    final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
    final review = tasks.where((t) => t.status == TaskStatus.review).length;
    final total = tasks.length;

    final sections = <_PieSection>[
      _PieSection("Hoàn thành", done, AppColors.statusDone),
      _PieSection("Đang làm", inProgress, AppColors.statusInProgress),
      _PieSection("Cần làm", todo, AppColors.statusTodo),
      _PieSection("Review", review, AppColors.statusReview),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Phân bổ trạng thái", style: AppTextStyles.heading3(isDark)),
          const SizedBox(height: 4),
          Text("Tổng $total công việc", style: AppTextStyles.caption(isDark)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: sections.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isTouched = i == _touchedIndex;
                    final value = s.count.toDouble();
                    return PieChartSectionData(
                      value: value == 0 ? 0.001 : value * _anim.value,
                      title: value > 0 ? "${(value / total * 100).round()}%" : "",
                      color: s.color,
                      radius: isTouched ? 70 : 60,
                      titleStyle: GoogleFonts.inter(
                        fontSize: isTouched ? 14 : 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: sections.map((s) => _legendItem(s.label, s.color, s.count, total, isDark)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, int count, int total, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          "$label ($count)",
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBarSection(List<TaskModel> tasks, bool isDark) {
    final Map<String, int> memberStats = {};
    for (var task in tasks) {
      if (task.status == TaskStatus.done) {
        for (var userId in task.assignees) {
          memberStats[userId] = (memberStats[userId] ?? 0) + 1;
        }
      }
    }

    if (memberStats.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hiệu suất thành viên", style: AppTextStyles.heading3(isDark)),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_alt_rounded, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(height: 12),
                  Text("Chưa có task hoàn thành", style: AppTextStyles.caption(isDark)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    final entries = memberStats.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value.toDouble() * _anim.value,
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary, AppColors.secondary],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 24,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hiệu suất thành viên", style: AppTextStyles.heading3(isDark)),
          const SizedBox(height: 4),
          Text("Task đã hoàn thành theo người phụ trách", style: AppTextStyles.caption(isDark)),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(
                          value.round().toString(),
                          style: AppTextStyles.caption(isDark),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < entries.length) {
                            final id = entries[idx].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "User ${idx + 1}",
                                style: AppTextStyles.caption(isDark),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${rod.toY.round()} task",
                          GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSection {
  final String label;
  final int count;
  final Color color;
  const _PieSection(this.label, this.count, this.color);
}
