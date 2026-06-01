import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Cấp quyền cho iOS / Android 13+
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Lấy FCM Token để gửi thông báo đích danh
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token của thiết bị: $token");

    // 3. Khởi tạo Local Notifications
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // 4. Lắng nghe thông báo khi App đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'protask_channel',
        'ProTask Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }
}
