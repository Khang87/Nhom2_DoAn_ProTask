import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  final Map<String, Map<String, String>> supportedLocales = {
    'vi': {'native': 'Tiếng Việt', 'vietnamese': 'Tiếng Việt'},
    'en': {'native': 'English', 'vietnamese': 'Tiếng Anh'},
    'ja': {'native': '日本語', 'vietnamese': 'Tiếng Nhật'},
    'ko': {'native': '한국어', 'vietnamese': 'Tiếng Hàn'},
    'th': {'native': 'ภาษาไทย', 'vietnamese': 'Tiếng Thái'},
  };

  static const Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'login': 'ĐĂNG NHẬP',
      'register': 'ĐĂNG KÝ',
      'register_title': 'Tạo tài khoản mới',
      'full_name': 'Họ và tên',
      'password': 'Mật khẩu',
      'email_hint': 'Tên đăng nhập / Email',
      'forgot_password': 'Quên mật khẩu?',
      // Các key mới cho màn hình Forgot Password
      'forgot_password_title': 'Quên mật khẩu?',
      'forgot_password_sub': 'Nhập email hoặc tên đăng nhập để nhận hướng dẫn thiết lập lại mật khẩu',
      'continue_btn': 'TIẾP TỤC',
    },
    'en': {
      'login': 'LOGIN',
      'register': 'REGISTER',
      'register_title': 'Create new account',
      'full_name': 'Full Name',
      'password': 'Password',
      'email_hint': 'Username / Email',
      'forgot_password': 'Forgot password?',
      'forgot_password_title': 'Forgot Password?',
      'forgot_password_sub': 'Enter your email or username to receive instructions to reset your password',
      'continue_btn': 'CONTINUE',
    },
    'ja': {
      'login': 'ログイン',
      'register': '登録',
      'register_title': '新しいアカウントを作成する',
      'full_name': '氏名',
      'password': 'パスワード',
      'email_hint': 'ユーザー名 / メール',
      'forgot_password': 'パスワードをお忘れですか？',
      'forgot_password_title': 'パスワードをお忘れですか？',
      'forgot_password_sub': 'パスワードを再設定するための手順を送信するには、メールアドレスまたはユーザー名を入力してください',
      'continue_btn': '次へ',
    },
    'ko': {
      'login': '로그인',
      'register': '등록하다',
      'register_title': '새 계정 만들기',
      'full_name': '성명',
      'password': '비밀번호',
      'email_hint': '사용자 이름 / 이메일',
      'forgot_password': '비밀번호를 잊으셨나요?',
      'forgot_password_title': '비밀번호를 잊으셨나요?',
      'forgot_password_sub': '비밀번호 재설정 안내를 받으려면 이메일이나 사용자 이름을 입력하세요',
      'continue_btn': '계속하다',
    },
    'th': {
      'login': 'เข้าสู่ hệ thống',
      'register': 'ลงทะเบียน',
      'register_title': 'สร้างบัญชีใหม่',
      'full_name': 'ชื่อ-นามสกุล',
      'password': 'รหัสผ่าน',
      'email_hint': 'ชื่อผู้ใช้ / อีเมล',
      'forgot_password': 'ลืมรหัสผ่าน?',
      'forgot_password_title': 'ลืมรหัสผ่าน?',
      'forgot_password_sub': 'ป้อนอีเมลหรือชื่อผู้ใช้ของคุณเพื่อรับคำแนะนำในการรีเซ็ตรหัสผ่าน',
      'continue_btn': 'ดำเนินการต่อ',
    },
  };

  String getText(String key) {
    // Thêm .trim() để xử lý trường hợp lỡ tay gõ dư dấu cách trong code giao diện
    return _localizedValues[_locale.languageCode]?[key.trim()] ?? key;
  }

  void setLocale(String langCode) {
    if (supportedLocales.containsKey(langCode)) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  String get currentLanguageNativeName {
    return supportedLocales[_locale.languageCode]?['native'] ?? 'Tiếng Việt';
  }
}