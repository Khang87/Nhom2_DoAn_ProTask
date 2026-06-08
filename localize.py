import os
import re

def update_file(file_path, import_line, init_provider_line, replacements):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'locale_provider.dart' not in content:
        content = content.replace("import '../model/task_model.dart';", "import '../model/task_model.dart';\nimport '../provider/locale_provider.dart';")

    if 'localeProvider = Provider.of<LocaleProvider>(context)' not in content and init_provider_line:
        content = content.replace("final isDark = Theme.of(context).brightness == Brightness.dark;", "final isDark = Theme.of(context).brightness == Brightness.dark;\n    final localeProvider = Provider.of<LocaleProvider>(context);")

    for old, new in replacements.items():
        content = content.replace(old, new)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

update_file('lib/screen/timeline_screen.dart', True, True, {
    '"Timeline"': 'localeProvider.getText("timeline_title")',
    '"${tasks.length} công việc"': 'localeProvider.getText("timeline_task_count", params: {"count": tasks.length.toString()})',
    '"Dự án quản lý"': 'localeProvider.getText("timeline_tab_managed")',
    '"Dự án tham gia"': 'localeProvider.getText("timeline_tab_participated")',
    '"Tất cả dự án"': 'localeProvider.getText("timeline_all_projects")',
    '"Tất cả"': 'localeProvider.getText("timeline_filter_all")',
    '"Chưa xong"': 'localeProvider.getText("timeline_filter_upcoming")',
    '"Hoàn thành"': 'localeProvider.getText("timeline_filter_done")'
})

update_file('lib/screen/charts_screen.dart', True, True, {
    '"Báo cáo & Phân tích"': 'localeProvider.getText("charts_title")',
    '"Tổng quan hiệu suất"': 'localeProvider.getText("charts_subtitle")',
    '"Báo cáo tổng thể (Tất cả dự án)"': 'localeProvider.getText("charts_all_projects")',
    '"Báo cáo dự án: ${p.title}"': 'localeProvider.getText("charts_project", params: {"name": p.title})',
    '"Chưa có dữ liệu thống kê"': 'localeProvider.getText("charts_empty_title")',
    '"Tạo và hoàn thành các task để xem báo cáo"': 'localeProvider.getText("charts_empty_desc")',
    '"Tổng quan"': 'localeProvider.getText("charts_summary")',
    '"Trạng thái Task"': 'localeProvider.getText("charts_task_status")'
})

update_file('lib/screen/calendar_screen.dart', True, True, {
    '"Lịch Công việc"': 'localeProvider.getText("calendar_title")',
    '"Deadline theo ngày"': 'localeProvider.getText("calendar_subtitle")',
    '_calendarFormat == CalendarFormat.month ? "Tuần" : "Tháng"': '_calendarFormat == CalendarFormat.month ? localeProvider.getText("calendar_format_week") : localeProvider.getText("calendar_format_month")',
    '"Hôm nay"': 'localeProvider.getText("calendar_today")',
    '"Không có task nào trong ngày này"': 'localeProvider.getText("calendar_empty_title")',
    '"Ngày tự do! 🎉"': 'localeProvider.getText("calendar_empty_desc")'
})

update_file('lib/screen/kanban_screen.dart', True, True, {
    '"Tìm kiếm task..."': 'localeProvider.getText("kanban_search")',
    '"Bộ lọc"': 'localeProvider.getText("kanban_filter")',
    '"Tất cả"': 'localeProvider.getText("timeline_filter_all")',
    '"Chưa bắt đầu"': 'localeProvider.getText("kanban_status_todo")',
    '"Đang làm"': 'localeProvider.getText("kanban_status_in_progress")',
    '"Đang duyệt"': 'localeProvider.getText("kanban_status_review")',
    '"Hoàn thành"': 'localeProvider.getText("kanban_status_done")',
    '"Tạo task mới"': 'localeProvider.getText("kanban_add_task")',
    '"Quá hạn"': 'localeProvider.getText("kanban_overdue")'
})

print('Done')
