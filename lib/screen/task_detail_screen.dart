import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../model/task_model.dart';
import '../model/comment_model.dart';
import '../provider/auth_provider.dart';
import '../provider/comment_provider.dart';
import '../provider/project_provider.dart';
import '../provider/task_provider.dart';
import '../service/storage_service.dart';
import '../service/firestore_service.dart';
import '../model/user_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final StorageService _storageService = StorageService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false).listenToComments(widget.task.taskId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    final newComment = CommentModel(
      commentId: '',
      userId: auth.userModel?.uid ?? 'unknown',
      userName: auth.userModel?.displayName ?? 'Anonymous',
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    commentProvider.addComment(widget.task.taskId, newComment);
    _commentController.clear();
  }

  Future<void> _uploadFile() async {
    List<File> files = await _storageService.pickFiles();
    if (files.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
      
      for (var file in files) {
        await _storageService.uploadAndAttachToTask(widget.task.taskId, file);
      }
      
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Đã tải file lên thành công!", style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            backgroundColor: AppColors.statusDone,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentProvider = Provider.of<CommentProvider>(context);

    final priorityColor = widget.task.priority == TaskPriority.high
        ? AppColors.priorityHigh
        : widget.task.priority == TaskPriority.medium
            ? AppColors.priorityMedium
            : AppColors.priorityLow;

    final isOverdue = widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(DateTime.now()) &&
        widget.task.status != TaskStatus.done;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
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
        title: Text("Chi tiết Task", style: AppTextStyles.heading3(isDark)),
        actions: [
          Consumer<ProjectProvider>(
            builder: (context, projectProvider, child) {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final userId = auth.userModel?.uid ?? '';
              final role = projectProvider.getUserRole(widget.task.projectId, userId);
              
              if (role == 'owner' || role == 'manager' || widget.task.assignees.contains(userId)) {
                return PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  onSelected: (val) async {
                    if (val == 'edit') {
                      _showEditTaskDialog(context, isDark);
                    } else if (val == 'delete') {
                      await Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.task.taskId);
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đã xóa task!"), backgroundColor: AppColors.statusDone),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text("Chỉnh sửa Task", style: AppTextStyles.body(isDark)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppColors.priorityHigh, size: 20),
                          const SizedBox(width: 8),
                          Text("Xóa Task", style: AppTextStyles.body(isDark).copyWith(color: AppColors.priorityHigh)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
                        Row(
                          children: [
                            StatusBadge(
                              label: widget.task.priority == TaskPriority.high
                                  ? "Ưu tiên Cao"
                                  : widget.task.priority == TaskPriority.medium
                                      ? "Ưu tiên Trung bình"
                                      : "Ưu tiên Thấp",
                              color: priorityColor,
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(
                              label: _statusLabel(widget.task.status),
                              color: _statusColor(widget.task.status),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              StatusBadge(label: "Quá hạn", color: AppColors.priorityHigh),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(widget.task.title, style: AppTextStyles.heading1(isDark)),
                        const SizedBox(height: 14),

                        // Meta info
                        if (widget.task.progress > 0 || widget.task.status == TaskStatus.done) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  child: LinearProgressIndicator(
                                    value: widget.task.status == TaskStatus.done ? 1.0 : widget.task.progress,
                                    minHeight: 8,
                                    backgroundColor: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.task.status == TaskStatus.done ? AppColors.statusDone : AppColors.primary
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${widget.task.status == TaskStatus.done ? 100 : (widget.task.progress * 100).toInt()}%",
                                style: AppTextStyles.captionBold(isDark).copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        Row(
                          children: [
                            if (widget.task.dueDate != null) ...[
                              _metaChip(
                                icon: Icons.calendar_today_rounded,
                                label: "Hạn: ${DateFormat('dd/MM/yyyy').format(widget.task.dueDate!)}",
                                color: isOverdue ? AppColors.priorityHigh : AppColors.primary,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.task.managerId.isNotEmpty) ...[
                              _metaChip(
                                icon: Icons.admin_panel_settings_rounded,
                                label: "Quản lý",
                                color: AppColors.statusReview,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.task.assignees.isNotEmpty)
                              _metaChip(
                                icon: Icons.people_rounded,
                                label: "${widget.task.assignees.length} người phụ trách",
                                color: AppColors.secondary,
                                isDark: isDark,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        if (widget.task.description.isNotEmpty) ...[
                          Text("Mô tả", style: AppTextStyles.heading3(isDark)),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Text(
                              widget.task.description,
                              style: AppTextStyles.body(isDark).copyWith(height: 1.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Attachments
                        _buildAttachments(isDark),
                        const SizedBox(height: 24),

                        // Discussion
                        Row(
                          children: [
                            Text("Thảo luận", style: AppTextStyles.heading3(isDark)),
                            const SizedBox(width: 10),
                            if (commentProvider.comments.isNotEmpty)
                              StatusBadge(
                                label: "${commentProvider.comments.length}",
                                color: AppColors.primary,
                                small: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildComments(commentProvider, isDark),
                        const SizedBox(height: 24),
                        
                        if (widget.task.status != TaskStatus.done && (widget.task.assignees.contains(Provider.of<AuthProvider>(context, listen: false).userModel?.uid) || Provider.of<ProjectProvider>(context, listen: false).getUserRole(widget.task.projectId, Provider.of<AuthProvider>(context, listen: false).userModel?.uid ?? '') == 'owner' || widget.task.managerId == Provider.of<AuthProvider>(context, listen: false).userModel?.uid))
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              label: "Đánh dấu Hoàn thành",
                              icon: Icons.check_circle_rounded,
                              onTap: () {
                                Provider.of<TaskProvider>(context, listen: false).updateStatus(widget.task.taskId, TaskStatus.done);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment input
          _buildCommentInput(isDark),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildAttachments(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tài liệu đính kèm", style: AppTextStyles.heading3(isDark)),
            GestureDetector(
              onTap: _uploadFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text("Thêm", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.task.attachments.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
                const SizedBox(width: 8),
                Text("Chưa có tài liệu nào", style: AppTextStyles.caption(isDark)),
              ],
            ),
          )
        else
          ...widget.task.attachments.map((file) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.insert_drive_file_rounded, color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(file.fileName, style: AppTextStyles.bodyMedium(isDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.download_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildComments(CommentProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
    }
    if (provider.comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("Hãy bắt đầu thảo luận!", style: AppTextStyles.body(isDark).copyWith(color: AppColors.primary)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.comments.length,
      itemBuilder: (context, index) {
        final comment = provider.comments[index];
        return _buildCommentItem(comment, isDark);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : "U",
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName, style: AppTextStyles.bodyMedium(isDark)),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm dd/MM').format(comment.timestamp),
                      style: AppTextStyles.caption(isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.lg),
                      bottomRight: Radius.circular(AppRadius.lg),
                    ),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Text(comment.content, style: AppTextStyles.body(isDark)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 12, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: AppShadows.bottomBar(isDark),
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: AppTextStyles.body(isDark),
              decoration: InputDecoration(
                hintText: "Nhập bình luận...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onSubmitted: (_) => _sendComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow(AppColors.primary),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return "Cần làm";
      case TaskStatus.in_progress: return "Đang làm";
      case TaskStatus.review: return "Review";
      case TaskStatus.done: return "Hoàn thành";
    }
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return AppColors.statusTodo;
      case TaskStatus.in_progress: return AppColors.statusInProgress;
      case TaskStatus.review: return AppColors.statusReview;
      case TaskStatus.done: return AppColors.statusDone;
    }
  }

  void _showEditTaskDialog(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController(text: widget.task.title);
    final descCtrl = TextEditingController(text: widget.task.description);
    DateTime? selectedDate = widget.task.dueDate;
    List<String> selectedAssignees = List.from(widget.task.assignees);
    TaskPriority selectedPriority = widget.task.priority;
    double selectedProgress = widget.task.progress;
    List<AttachmentModel> currentAttachments = List.from(widget.task.attachments);
    List<File> newLocalFiles = [];

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final project = projectProvider.projects.firstWhere((p) => p.projectId == widget.task.projectId);
    final memberIds = project.members.map((m) => m.userId).toList();
    final usersFuture = FirestoreService().getUsersByIds(memberIds);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.uid ?? '';
    final role = projectProvider.getUserRole(widget.task.projectId, userId);
    final isManager = role == 'owner' || role == 'manager' || widget.task.managerId == userId;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    Text("Chỉnh sửa Task", style: AppTextStyles.heading2(isDark)),
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

                    if (isManager) ...[
                      Text("Tiến độ: ${(selectedProgress * 100).toInt()}%", style: AppTextStyles.captionBold(isDark)),
                      Slider(
                        value: selectedProgress,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setSheet(() => selectedProgress = val);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

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
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                    Text("Tệp đính kèm hiện tại", style: AppTextStyles.captionBold(isDark)),
                    const SizedBox(height: 8),
                    if (currentAttachments.isEmpty && newLocalFiles.isEmpty)
                      Text("Không có tệp đính kèm", style: AppTextStyles.body(isDark)),
                    
                    if (currentAttachments.isNotEmpty)
                      Column(
                        children: currentAttachments.map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    f.fileName,
                                    style: AppTextStyles.bodyMedium(isDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setSheet(() => currentAttachments.remove(f));
                                  },
                                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.priorityHigh),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    if (newLocalFiles.isNotEmpty)
                      Column(
                        children: newLocalFiles.map((f) {
                          String fName = f.path.split(Platform.pathSeparator).last;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.statusInProgress),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fName + " (mới)",
                                    style: AppTextStyles.bodyMedium(isDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setSheet(() => newLocalFiles.remove(f));
                                  },
                                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.priorityHigh),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        List<File> picked = await StorageService().pickFiles();
                        if (picked.isNotEmpty) {
                          setSheet(() {
                            newLocalFiles.addAll(picked);
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
                              "Tải tệp đính kèm mới",
                              style: AppTextStyles.bodyMedium(isDark).copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.isNotEmpty) {
                            // Upload new files
                            List<AttachmentModel> allAttachments = List.from(currentAttachments);
                            if (newLocalFiles.isNotEmpty) {
                              final storageService = StorageService();
                              for (var file in newLocalFiles) {
                                AttachmentModel? attachment = await storageService.uploadFile('tasks/${widget.task.taskId}', file);
                                if (attachment != null) {
                                  allAttachments.add(attachment);
                                }
                              }
                            }
                            
                            if (context.mounted) {
                              Provider.of<TaskProvider>(context, listen: false).updateTaskDetails(
                                widget.task.taskId,
                                titleCtrl.text.trim(),
                                descCtrl.text.trim(),
                                selectedPriority,
                                selectedAssignees,
                                selectedDate,
                                selectedProgress,
                                allAttachments,
                              );
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        ),
                        child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.flag_rounded, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
