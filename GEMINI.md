# ProTask Project Documentation

## Project Overview
ProTask là một ứng dụng quản lý dự án và công việc nhóm được phát triển bằng Flutter. Ứng dụng cung cấp các tính năng cốt lõi như quản lý nhiệm vụ, theo dõi tiến độ qua dòng thời gian (timeline), tích hợp lịch (calendar), báo cáo bằng biểu đồ (charts) và hệ thống thông báo.

### Main Technologies
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Backend:** Firebase (Authentication, Cloud Firestore, Firebase Messaging)
- **Local Storage:** SQLite (sqflite)
- **UI Libraries:**
    - `table_calendar`: Quản lý lịch biểu.
    - `fl_chart`: Hiển thị biểu đồ báo cáo.
    - `timeline_tile`: Hiển thị tiến độ công việc theo dòng thời gian.
- **Notifications:** `flutter_local_notifications`

## Architecture
Dự án tuân theo cấu trúc phân lớp cơ bản của Flutter:
- `lib/model/`: Định nghĩa các đối tượng dữ liệu (User, Project, Task).
- `lib/provider/`: Xử lý logic nghiệp vụ và quản lý trạng thái ứng dụng.
- `lib/screen/`: Các màn hình giao diện người dùng.
- `lib/database/`: Lớp truy xuất dữ liệu cục bộ SQLite.
- `lib/service/`: Các dịch vụ bên ngoài như thông báo.

## Building and Running
Để chạy dự án, hãy sử dụng các lệnh sau:
- **Cài đặt thư viện:** `flutter pub get`
- **Chạy ứng dụng:** `flutter run`
- **Dọn dẹp dự án:** `flutter clean`

## Development Conventions
- **Naming Style:** Sử dụng `snake_case` cho tên tệp tin và `lowerCamelCase` cho biến/hàm.
- **State Management:** Ưu tiên sử dụng `Provider` để quản lý trạng thái giữa các Widget.
- **Database:** Khi cập nhật cấu trúc bảng trong `DatabaseHelper`, hãy tăng `version` của database để thực hiện `onUpgrade`.
- **UI Consistency:** Tuân thủ hệ màu và theme (Dark/Light) đã được thiết lập trong `ThemeProvider`.

## Key Files
- `lib/main.dart`: Điểm khởi đầu của ứng dụng và cấu hình MultiProvider.
- `lib/database/database_helper.dart`: Quản lý schema và các truy vấn SQLite.
- `lib/screen/home_screen.dart`: Màn hình điều hướng chính và giao diện tổng quan dự án.
- `pubspec.yaml`: Quản lý các phụ thuộc và cấu hình dự án.
