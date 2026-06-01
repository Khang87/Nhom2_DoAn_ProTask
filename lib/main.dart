import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_theme.dart';

// Providers
import 'package:protask/provider/theme_provider.dart';
import 'package:protask/provider/locale_provider.dart';
import 'package:protask/provider/auth_provider.dart';
import 'package:protask/provider/project_provider.dart';
import 'package:protask/provider/task_provider.dart';
import 'package:protask/provider/comment_provider.dart';
import 'package:protask/provider/chat_provider.dart';
import 'package:protask/service/notification_service.dart';

// Screens
import 'package:protask/screen/login_screen.dart';
import 'package:protask/screen/register_screen.dart';
import 'package:protask/screen/forgotpass_screen.dart';
import 'package:protask/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
  } catch (e) {
    print("Lỗi khởi tạo: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
      title: 'ProTask',

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),

      // LOGIC ĐIỀU HƯỚNG TỰ ĐỘNG
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const _SplashScreen();
          }

          if (auth.isLoggedIn) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),

      routes: {
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.brand),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Icons.task_alt_rounded, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'ProTask',
                style: AppTextStyles.display(false).copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Quản lý dự án thông minh',
                style: AppTextStyles.body(false).copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
