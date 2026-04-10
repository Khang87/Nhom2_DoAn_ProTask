import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Providers
import 'package:protask/provider/theme_provider.dart';
import 'package:protask/provider/locale_provider.dart';
import 'package:protask/provider/auth_provider.dart';

// Screens
import 'package:protask/screen/login_screen.dart';
import 'package:protask/screen/register_screen.dart';
import 'package:protask/screen/forgotpass_screen.dart';
import 'package:protask/screen/home_screen.dart';

void main() async {
  // Đảm bảo các dịch vụ hệ thống đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Lỗi khởi tạo Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // Khởi tạo AuthProvider sẽ tự động gọi _checkCurrentUser()
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProTask Management',

      // Điều chỉnh Theme theo hệ thống hoặc lựa chọn của Hùng
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      // 🔥 LOGIC ĐIỀU HƯỚNG TỰ ĐỘNG
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // ⏳ 1. Trong khi đang nạp dữ liệu từ SQLite/Firebase
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Đang khởi động ProTask...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          // ✅ 2. Nếu đã có dữ liệu người dùng (Đã login)
          if (auth.isLoggedIn) {
            return const HomeScreen();
          }

          // ❌ 3. Nếu chưa đăng nhập
          return const LoginScreen();
        },
      ),

      // Các routes để điều hướng bằng Navigator.pushNamed
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}