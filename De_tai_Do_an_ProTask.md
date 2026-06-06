# BÁO CÁO ĐỀ XUẤT ĐỀ TÀI NGHIÊN CỨU VÀ PHÁT TRIỂN PHẦN MỀM

**Tên đề tài:** Ứng dụng Quản lý Dự án và Công việc Nhóm (ProTask)  
**Nền tảng triển khai:** Mobile Application (Android & iOS)  
**Đơn vị thực hiện:** Khoa Công nghệ Thông tin - Trường Đại học Công thương TP.HCM (HUIT)  
**Sinh viên thực hiện:** 1. Bùi Quốc Hùng  
2. Nguyễn Phát Huy  
3. Nguyễn Trường Khang  

---

## MỤC LỤC
1. [GIỚI THIỆU ĐỀ TÀI](#1-giới-thiệu-đề-tài)
   - 1.1. Đặt vấn đề
   - 1.2. Mục tiêu đề tài
   - 1.3. Đối tượng và Phạm vi nghiên cứu
2. [CÔNG NGHỆ SỬ DỤNG (TECHNOLOGY STACK)](#2-công-nghệ-sử-dụng-technology-stack)
   - 2.1. Lý do lựa chọn giải pháp
   - 2.2. Chi tiết các công nghệ cốt lõi
3. [MÔ HÌNH CHỨC NĂNG (PRODUCT FEATURES)](#3-mô-hình-chức-năng-product-features)
   - 3.1. Phân hệ Xác thực & Định danh (Authentication Module)
   - 3.2. Phân hệ Quản lý Dự án & Công việc (Core Task Management)
   - 3.3. Phân hệ Cộng tác & Tương tác (Collaboration Module)
   - 3.4. Phân hệ Hiển thị Trực quan & Báo cáo (Dashboard & Charts)
   - 3.5. Phân hệ Dịch vụ Mở rộng (Third-party Services)
4. [QUY TRÌNH HOẠT ĐỘNG (WORKFLOW & PROCESS)](#4-quy-trình-hoạt-động-workflow--process)
5. [THIẾT KẾ CƠ SỞ DỮ LIỆU (DATABASE SCHEMA - FIRESTORE)](#5-thiết-kế-cơ-sở-dữ-liệu-database-schema---firestore)
6. [KIẾN TRÚC PHẦN MỀM & QUẢN LÝ TRẠNG THÁI (ARCHITECTURE & STATE MANAGEMENT)](#6-kiến-trúc-phần-mềm--quản-lý-trạng-thái-architecture--state-management)
7. [KẾ HOẠCH TRIỂN KHAI DỰ KIẾN](#7-kế-hoạch-triển-khai-dự-kiến)

---

## 1. GIỚI THIỆU ĐỀ TÀI

### 1.1. Đặt vấn đề
Trong kỷ nguyên chuyển đổi số, làm việc nhóm và quản lý dự án theo mô hình cộng tác từ xa hoặc hybrid đã trở thành xu hướng tất yếu tại các doanh nghiệp và tổ chức giáo dục. Tuy nhiên, việc theo dõi tiến độ, phân chia nguồn lực và kiểm soát thời hạn công việc (deadline) thường gặp nhiều khó khăn do thiếu công cụ quản lý trực quan. Các thành viên dễ bị bỏ sót luồng thông tin, chồng chéo nhiệm vụ hoặc phân bổ thời gian không hợp lý. Để giải quyết bài toán này, đề tài **ProTask** được nghiên cứu nhằm xây dựng một ứng dụng di động trực quan, hỗ trợ tối ưu hóa quy trình làm việc và nâng cao hiệu suất cộng tác.

### 1.2. Mục tiêu đề tài
- **Về mặt kỹ thuật:** Nghiên cứu và áp dụng thành thạo framework phát triển đa nền tảng Flutter (Dart) cùng hệ sinh thái lưu trữ đám mây thời gian thực Firebase.
- **Về mặt ứng dụng:** Phát triển một ứng dụng di động hoàn chỉnh có giao diện trực quan (Kanban, Lịch biểu, Biểu đồ xu hướng), đáp ứng nhu cầu quản lý dự án thực tế giống các hệ thống lớn (Jira, Trello, Asana).

### 1.3. Đối tượng và Phạm vi nghiên cứu
- **Đối tượng nghiên cứu:** Các mô hình quản lý dự án (Agile/Scrum, Kanban), giải pháp kiến trúc phần mềm di động, cơ chế đồng bộ dữ liệu thời gian thực (Real-time database).
- **Phạm vi ứng dụng:** Ứng dụng tập trung vào đối tượng người dùng là các nhóm làm việc vừa và nhỏ (Startup, nhóm sinh viên nghiên cứu, phòng ban doanh nghiệp), hỗ trợ tối đa trên hai nền tảng phổ biến Android và iOS.

---

## 2. CÔNG NGHỆ SỬ DỤNG (TECHNOLOGY STACK)

### 2.1. Lý do lựa chọn giải pháp
Hệ thống ưu tiên sử dụng kiến trúc Không máy chủ (Serverless) thông qua Firebase kết hợp với framework Flutter. Sự kết hợp này giúp giảm thiểu thời gian xây dựng và vận hành hạ tầng backend truyền thống, cho phép tập trung tối đa vào tối ưu hóa trải nghiệm người dùng (UX/UI) và các logic nghiệp vụ phức tạp của dự án.

### 2.2. Chi tiết các công nghệ cốt lõi
- **Ngôn ngữ & Framework:** `Flutter` (Phiên bản 3.x) & `Dart`. Hỗ trợ biên dịch native ra mã máy giúp ứng dụng đạt hiệu năng tối đa mượt mà như app thuần (Native app).
- **Quản lý trạng thái (State Management):** Sử dụng mẫu kiến trúc `BLoC (Business Logic Component)` hoặc `Provider`. Đảm bảo phân tách rõ ràng giữa giao diện biểu diễn (UI) và logic nghiệp vụ, tối ưu hóa bộ nhớ và tăng tốc độ phản hồi.
- **Cơ sở dữ liệu chính:** `Firebase Cloud Firestore`. Cơ sở dữ liệu NoSQL hướng tài liệu (Document-oriented), tự động đồng bộ hóa dữ liệu xuống thiết bị theo thời gian thực qua giao thức WebSockets.
- **Xác thực người dùng:** `Firebase Authentication`. Hỗ trợ mã hóa, quản lý phiên đăng nhập bảo mật thông qua Email/Password và Đăng nhập một chạm bằng tài khoản Google (Google Sign-In).
- **Lưu trữ tài nguyên:** `Firebase Cloud Storage`. Nơi lưu trữ bảo mật cho các tệp tin đính kèm tài liệu công việc, ảnh đại diện người dùng với cơ chế phân quyền chặt chẽ.
- **Thư viện bên thứ ba trọng tâm:**
  - `fl_chart`: Thư viện xử lý dựng biểu đồ vector sắc nét, mượt mà phục vụ phân tích báo cáo.
  - `table_calendar`: Thư viện tùy biến lịch biểu chuyên sâu hỗ trợ quản lý vòng đời deadline.
  - `firebase_messaging`: Giải pháp Firebase Cloud Messaging (FCM) xử lý đẩy thông báo đẩy (Push Notification) thời gian thực.
  - `file_picker`: Hỗ trợ tương tác hệ thống tệp native trên Android/iOS để chọn và tải tệp đính kèm.

---

## 3. MÔ HÌNH CHỨC NĂNG (PRODUCT FEATURES)

Ứng dụng ProTask được cấu trúc hóa thành 5 phân hệ chức năng logic tương hỗ:

```
[Hệ thống ProTask]
  ├── Phân hệ Xác thực & Định danh (Firebase Auth)
  ├── Phân hệ Quản lý Dự án & Công việc (Core Logic)
  ├── Phân hệ Cộng tác & Tương tác (Comments & Storage)
  ├── Phân hệ Hiển thị Trực quan & Báo cáo (fl_chart & Calendar)
  └── Phân hệ Dịch vụ Mở rộng (FCM & Google Calendar API)
```

### 3.1. Phân hệ Xác thực & Định danh (Authentication Module)
- Đăng ký tài khoản hệ thống qua email hoặc liên kết tài khoản Google nhanh chóng.
- Tính năng phục hồi mật khẩu tự động qua email xác thực an toàn.
- Quản lý thông tin hồ sơ cá nhân (Profile): Cập nhật họ tên, ảnh đại diện (avatar), thông tin liên hệ.
- Phân quyền theo vai trò trong dự án: **Project Owner** (Chủ dự án - toàn quyền), **Project Manager** (Quản lý - điều phối task), **Member** (Thành viên - thực hiện và báo cáo).

### 3.2. Phân hệ Quản lý Dự án & Công việc (Core Task Management)
- **Quản lý không gian làm việc (Project Workspace):** Khởi tạo, chỉnh sửa thông tin hoặc lưu trữ/xóa dự án. Người dùng có thể quản trị danh sách thành viên tham gia bằng cách mời qua email.
- **Nghiệp vụ quản lý Task:**
  - Khởi tạo đầu việc kèm thông tin chi tiết: Tiêu đề, mô tả yêu cầu, ngày bắt đầu và thời hạn hoàn thành (Deadline).
  - Phân loại độ ưu tiên rõ ràng: Thấp (Low), Trung bình (Medium), Cao (High).
  - Thiết lập trạng thái vòng đời công việc: Cần làm (To Do) $
ightarrow$ Đang xử lý (In Progress) $
ightarrow$ Chờ kiểm duyệt (Review) $
ightarrow$ Hoàn thành (Done).
  - Gán người chịu trách nhiệm chính (Assignee) trực tiếp cho một hoặc nhiều thành viên trong dự án.

### 3.3. Phân hệ Cộng tác & Tương tác (Collaboration Module)
- **Hệ thống bình luận (Task Comments):** Luồng thảo luận thời gian thực tích hợp bên trong từng task chi tiết. Hỗ trợ tính năng nhắc tên thành viên nhóm bằng ký tự `@` để thu hút sự chú ý.
- **Quản lý tài nguyên đính kèm:** Cho phép tải lên và lưu trữ các tệp ảnh chụp minh họa kết quả, tài liệu văn bản, báo cáo đính kèm trực tiếp vào không gian lưu trữ đám mây của task.

### 3.4. Phân hệ Hiển thị Trực quan & Báo cáo (Dashboard & Charts)
- **Giao diện Bảng Kanban:** Trực quan hóa tiến độ dự án dưới dạng các cột trạng thái. Hỗ trợ thao tác kéo-thả (Drag and Drop) linh hoạt để cập nhật nhanh trạng thái của task.
- **Màn hình Lịch biểu (Calendar View):** Tổng hợp và phân phối toàn bộ thời hạn công việc (deadlines) trong tháng lên giao diện lịch trực quan để tránh trùng lặp lịch trình.
- **Màn hình Báo cáo & Thống kê (Dashboard Analytics):**
  - Sử dụng biểu đồ tròn (`Pie Chart`) minh họa tỷ lệ phân bổ trạng thái công việc hiện tại của dự án.
  - Biểu đồ cột/biểu đồ tiến độ biểu diễn hiệu suất hoàn thành công việc của từng thành viên trong nhóm, giúp đánh giá công bằng và trực quan năng lực xử lý đầu việc.
- **Bộ lọc & Tìm kiếm thông minh:** Hỗ trợ lọc nhanh các công việc theo mức độ ưu tiên, trạng thái, hoặc lọc đích danh các task được gán riêng cho bản thân người dùng.

### 3.5. Phân hệ Dịch vụ Mở rộng (Third-party Services)
- **Đồng bộ Google Calendar:** Tích hợp Google Calendar API giúp đồng bộ hóa tự động tất cả deadline từ ứng dụng ProTask sang lịch cá nhân của người dùng trên hệ sinh thái Google.
- **Thông báo thời gian thực:** Đẩy thông báo tức thời (Push notifications) thông qua dịch vụ FCM khi: có dự án mới, được phân công task mới, task sắp đến hạn (trước 2 tiếng/1 ngày), hoặc có lượt bình luận tương tác mới.

---

## 4. QUY TRÌNH HOẠT ĐỘNG (WORKFLOW & PROCESS)

Quy trình vận hành chuẩn của ProTask mô phỏng lại luồng làm việc thực tế của các công cụ quốc tế:

```
[Bắt đầu] ──> Đăng nhập/Đăng ký ──> Tạo/Tham gia Dự án ──> Thêm thành viên
                                                               │
┌──────────────────────────────────────────────────────────────┘
│
└──> Tạo Công việc (Set Ưu tiên, Deadline, Gán Assignee)
       │
       ├──> Thành viên nhận Task ──> Chuyển trạng thái sang "In Progress"
       │                                     │
       ├──> Thảo luận, đính kèm tài liệu ────┘
       │
       └──> Hoàn thành Task ──> Chuyển sang "Done" ──> Hệ thống cập nhật Biểu đồ Báo cáo
```

1. **Bước 1 (Khởi tạo không gian):** Người quản lý (Project Manager) đăng nhập, khởi tạo dự án mới và thêm các thành viên trong đội ngũ vào bằng Email.
2. **Bước 2 (Lập kế hoạch phân rã đầu việc):** Người quản lý tiến hành tạo các Task, thiết lập chi tiết thuộc tính (Deadline, Priority) và chỉ định người thực hiện (Assignee). Lúc này hệ thống kích hoạt push notification gửi đến thiết bị của thành viên được gán.
3. **Bước 3 (Thực thi & Tương tác đồng bộ):** Thành viên mở ứng dụng, theo dõi danh sách việc cần làm qua Tab cá nhân hoặc Bảng Kanban tổng thể. Khi bắt đầu xử lý, thành viên kéo thả task sang cột `In Progress`. Trong quá trình thực hiện, các thành viên cập nhật tiến độ bằng cách bình luận hoặc đính kèm tệp kết quả.
4. **Bước 4 (Nghiệm thu & Đóng Task):** Khi hoàn thành, task được chuyển sang trạng thái `Done`. Hệ thống tự động ghi nhận dữ liệu mới, tính toán lại tỷ lệ phần trăm và cập nhật ngay lập tức lên màn hình biểu đồ Dashboard Analytics tổng của dự án.

---

## 5. THIẾT KẾ CƠ SỞ DỮ LIỆU (DATABASE SCHEMA - FIRESTORE)

Cơ sở dữ liệu được tổ chức theo mô hình NoSQL của Cloud Firestore, tối ưu hóa cấu trúc phẳng để tăng tốc độ truy vấn thời gian thực và giảm thiểu chi phí đọc/ghi dữ liệu.

### 5.1. Collection: `users`
Lưu trữ toàn bộ thông tin định danh và cấu hình cá nhân của người dùng.
- `uid`: **String** (Primary Key - Trùng với Firebase Auth UID)
- `display_name`: **String** (Tên hiển thị)
- `email`: **String** (Địa chỉ email đăng ký)
- `photo_url`: **String** (Đường dẫn ảnh đại diện lưu trên Cloud Storage)
- `joined_projects`: **Array<String>** (Mảng danh sách các `project_id` mà user này đang tham gia)
- `created_at`: **Timestamp** (Thời gian khởi tạo tài khoản)

### 5.2. Collection: `projects`
Lưu trữ thông tin tổng quan cấp dự án.
- `project_id`: **String** (Primary Key - Tự động tạo)
- `title`: **String** (Tên dự án)
- `description`: **String** (Mô tả chi tiết dự án)
- `owner_id`: **String** (UID của người tạo dự án)
- `members`: **Array<Map>** (Mảng danh sách thành viên chứa thông tin chi tiết về vai trò)
  - `user_id`: **String** (Tham chiếu tới `users.uid`)
  - `role`: **String** (`"owner"`, `"manager"`, `"member"`)
- `created_at`: **Timestamp** (Thời gian tạo dự án)

### 5.3. Collection: `tasks`
Lưu trữ thông tin chi tiết của từng đầu việc. Có thể thiết kế dưới dạng Root Collection với trường `project_id` để tối ưu hóa truy vấn chéo.
- `task_id`: **String** (Primary Key - Tự động tạo)
- `project_id`: **String** (Foreign Key - Tham chiếu tới `projects.project_id`)
- `title`: **String** (Tiêu đề công việc)
- `description`: **String** (Mô tả chi tiết công việc)
- `status`: **String** (Trạng thái task: `"todo"`, `"in_progress"`, `"review"`, `"done"`)
- `priority`: **String** (Độ ưu tiên: `"low"`, `"medium"`, `"high"`)
- `assignees`: **Array<String>** (Danh sách các `user_id` phụ trách chính công việc này)
- `start_date`: **Timestamp** (Ngày bắt đầu)
- `due_date`: **Timestamp** (Ngày hết hạn - Deadline)
- `attachments`: **Array<Map>** (Danh sách các tài liệu đính kèm)
  - `file_name`: **String** (Tên tệp)
  - `file_url`: **String** (Đường dẫn tải tệp trên Cloud Storage)
  - `uploaded_at`: **Timestamp** (Thời gian tải lên)
- `created_at`: **Timestamp** (Thời gian tạo task)

### 5.4. Sub-Collection: `comments` (Nằm trong tài liệu của từng `task`)
Lưu trữ lịch sử trao đổi, thảo luận nội bộ của đầu việc.
- Path: `/tasks/{task_id}/comments/{comment_id}`
- `comment_id`: **String** (Primary Key)
- `user_id`: **String** (UID của người bình luận)
- `user_name`: **String** (Tên người bình luận hỗ trợ hiển thị nhanh)
- `content`: **String** (Nội dung văn bản bình luận)
- `timestamp`: **Timestamp** (Thời gian gửi bình luận)

### 5.5. Collection: `notifications`
Quản lý lịch sử và trạng thái hiển thị thông báo cho từng cá nhân.
- `notification_id`: **String** (Primary Key)
- `receiver_id`: **String** (UID của người nhận thông báo - Dùng để lập chỉ mục truy vấn)
- `title`: **String** (Tiêu đề thông báo)
- `body`: **String** (Nội dung chi tiết thông báo)
- `data_payload`: **Map** (Dữ liệu đính kèm phục vụ việc điều hướng màn hình khi nhấn vào thông báo, ví dụ: `{"project_id": "...", "task_id": "..."}`)
- `is_read`: **Boolean** (Trạng thái đã đọc hay chưa)
- `created_at`: **Timestamp** (Thời gian phát hành thông báo)

---

## 6. KIẾN TRÚC PHẦN MỀM & QUẢN LÝ TRẠNG THÁI (ARCHITECTURE & STATE MANAGEMENT)

Nhằm đảm bảo dự án có khả năng bảo trì cao, dễ dàng mở rộng tính năng và giúp nhiều thành viên có thể lập trình đồng thời không bị xung đột, mã nguồn Flutter sẽ áp dụng nghiêm ngặt theo **Clean Architecture** phân rã làm 3 tầng độc lập:

1. **Presentation Layer (Tầng hiển thị):** Chứa toàn bộ các Flutter Widgets giao diện UI (Màn hình Kanban, Dashboard, Calendar) và các khối xử lý trạng thái (`BLoC` hoặc `ChangeNotifier` của `Provider`). Tầng này chỉ nhận tương tác từ người dùng và thể hiện trạng thái ra màn hình.
2. **Domain Layer (Tầng nghiệp vụ cốt lõi):** Là trung tâm xử lý logic của ứng dụng, hoàn toàn độc lập với môi trường bên ngoài (không phụ thuộc vào UI hay DB). Chứa các mô hình thực thể dữ liệu gốc (`Entities`) và các ca sử dụng chức năng cụ thể (`UseCases` ví dụ: `CreateTaskUseCase`, `AssignUserUseCase`).
3. **Data Layer (Tầng dữ liệu):** Chịu trách nhiệm trực tiếp giao tiếp với hạ tầng bên ngoài. Chứa các `Repositories Implementation` để điều phối luồng lấy dữ liệu từ mạng đám mây (`Remote Data Source` - Firebase Firestore) hoặc lưu cấu hình tạm xuống bộ nhớ thiết bị (`Local Data Source`).

---

## 7. KẾ HOẠCH TRIỂN KHAI DỰ KIẾN

Lộ trình xây dựng sản phẩm đồ án được chia thành 4 giai đoạn cụ thể:

- **Giai đoạn 1: Phân tích & Đặc tả yêu cầu (Tuần 1 - Tuần 2)**
  - Hoàn thiện đề cương chi tiết tài liệu đặc tả chức năng.
  - Phác thảo thiết kế giao diện wireframe cơ bản của các màn hình chính trên Figma.
- **Giai đoạn 2: Thiết kế hạ tầng & Xây dựng Cơ sở dữ liệu (Tuần 3 - Tuần 4)**
  - Cấu hình phân tầng các thư mục dự án Flutter theo chuẩn Clean Architecture.
  - Khởi tạo Project trên Firebase Console, thiết lập các quy tắc bảo mật (Security Rules) cho Cloud Firestore và Cloud Storage.
- **Giai đoạn 3: Lập trình chức năng cốt lõi (Tuần 5 - Tuần 8)**
  - Triển khai Module Đăng nhập và phân quyền hệ thống.
  - Xây dựng giao diện kéo thả Kanban, biểu đồ thống kê với `fl_chart`, liên kết cấu hình `table_calendar`.
  - Viết logic kết nối API xử lý luồng sự kiện Real-time và xử lý đồng bộ Google Calendar API.
- **Giai đoạn 4: Kiểm thử, Tối ưu & Hoàn thiện báo cáo (Tuần 9 - Tuần 10)**
  - Tiến hành kiểm thử hộp đen (Black-box testing) hiệu năng ứng dụng, xử lý các lỗi tràn màn hình (overflow boundary) hoặc xung đột bất đồng bộ (async/await).
  - Tối ưu mã nguồn, đóng gói xuất bản tệp cài đặt thử nghiệm (`.apk` cho Android và `.ipa` cho iOS). Hoàn thiện quyển báo cáo đồ án đề tài gửi Hội đồng chuyên môn.

---

## 8. CÁC TÍNH NĂNG MỚI CẬP NHẬT (UPDATE LOG)

Dưới đây là danh sách các tính năng nâng cao vừa được hoàn thiện để người dùng / QA có thể tiến hành test-case:

### 8.1. Quản trị Dự án và Thành viên (Admin Role)
- **Xóa dự án (Delete Project):**
  - **Cách test:** Đăng nhập với tư cách Owner -> Vào màn hình chi tiết dự án (Bảng Kanban) -> Nhấn vào biểu tượng ⚙️ (Cài đặt góc phải) -> Chọn "Xóa dự án".
  - **Kết quả mong muốn:** Dự án và toàn bộ thành viên, task liên quan sẽ bị xóa khỏi hệ thống.
- **Quản lý Thành viên (Manage Members):**
  - **Cách test:** Tại menu ⚙️ (Cài đặt) -> Chọn "Quản lý thành viên". Sẽ hiện ra danh sách các thành viên trong dự án.
  - **Kết quả mong muốn:**
    - Owner có thể Kick (Xóa) thành viên.ơ
    - Owner có thể Thăng cấp (Promote) thành viên lên làm Manager.
    - Owner có thể Hạ cấp (Demote) Manager xuống làm Member.
- **Xóa Công việc (Delete Task):**
  - **Cách test:** Vào chi tiết một Task (chỉ dành cho Owner, Manager hoặc người được gán Task) -> Nhấn vào biểu tượng `⋮` góc trên cùng -> Chọn "Xóa Task".
  - **Kết quả mong muốn:** Task sẽ bị xóa và cập nhật lại số lượng trên Kanban.

### 8.2. Liên kết Tài khoản và Nâng cấp Bảo mật (Account Linking)
- **Liên kết Số điện thoại với Gmail:**
  - **Cách test:** Đăng nhập bằng tài khoản Gmail -> Vào tab "Hồ sơ cá nhân" (Profile) -> Nhập số điện thoại -> Nhấn "Gửi mã OTP" -> Nhập OTP để xác thực.
  - **Kết quả mong muốn:** Số điện thoại sẽ được liên kết thành công. Lần đăng nhập sau có thể sử dụng SĐT này để đăng nhập trực tiếp vào tài khoản đó (Tính đồng nhất tài khoản). 
  - *Lưu ý:* Phía Firebase Auth đã cấu hình cho phép Link Account.

### 8.3. Tùy chỉnh Hồ sơ cá nhân (Profile Customization)
- **Cập nhật Ảnh đại diện (Upload Avatar):**
  - **Cách test:** Vào Profile -> Nhấn vào hình tròn Avatar -> Ứng dụng mở thư viện ảnh -> Chọn ảnh.
  - **Kết quả mong muốn:** Ảnh được tải lên Firebase Storage và tự động lưu vào User Profile.
- **Đổi Tên hiển thị (Edit Display Name):**
  - **Cách test:** Vào Profile -> Nhấn vào biểu tượng cây bút `✏️` cạnh tên hiển thị -> Nhập tên mới -> Lưu.
  - **Kết quả mong muốn:** Tên người dùng sẽ cập nhật trên toàn hệ thống (bao gồm danh sách thành viên trong dự án).
