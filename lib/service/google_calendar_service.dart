import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../model/task_model.dart';

class GoogleCalendarService {
  // Yêu cầu quyền truy cập lịch (Phải được cấp lúc đăng nhập Google)
  static const List<String> scopes = [
    calendar.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

  // Phương thức đồng bộ Task lên Google Calendar
  Future<void> syncTaskToCalendar(TaskModel task) async {
    try {
      // 1. Kiểm tra và xác thực Google Sign In (kèm scope Calendar)
      var googleUser = _googleSignIn.currentUser;
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Đồng bộ thất bại: Người dùng chưa đăng nhập Google.");
        return;
      }

      // 2. Lấy HTTP Client có đính kèm Access Token
      var httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print("Lỗi xác thực Client với Google API.");
        return;
      }

      // 3. Khởi tạo Calendar API
      final calendarApi = calendar.CalendarApi(httpClient);

      // 4. Tạo đối tượng Sự kiện (Event)
      if (task.dueDate == null) {
        print("Task không có deadline, bỏ qua đồng bộ.");
        return;
      }

      // Mặc định tạo sự kiện bắt đầu từ 8h sáng ngày hạn chót và kết thúc lúc 17h
      final startDateTime = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day, 8, 0, 0);
      final endDateTime = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day, 17, 0, 0);

      calendar.Event event = calendar.Event(
        summary: "[ProTask] ${task.title}",
        description: "${task.description}\n\nĐộ ưu tiên: ${task.priority.toString().split('.').last}",
        start: calendar.EventDateTime(dateTime: startDateTime, timeZone: "Asia/Ho_Chi_Minh"),
        end: calendar.EventDateTime(dateTime: endDateTime, timeZone: "Asia/Ho_Chi_Minh"),
      );

      // 5. Thêm sự kiện vào lịch chính (primary) của người dùng
      await calendarApi.events.insert(event, "primary");
      print("Đồng bộ Task '${task.title}' lên Google Calendar thành công!");

    } catch (e) {
      print("Lỗi khi đồng bộ Google Calendar: $e");
    }
  }
}
