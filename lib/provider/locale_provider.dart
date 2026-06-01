import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('vi');
  Map<String, dynamic> _localizedValues = {};
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _isLoaded;

  final Map<String, Map<String, String>> supportedLocales = {
    'vi': {'native': 'Tiếng Việt', 'vietnamese': 'Tiếng Việt'},
    'en': {'native': 'English', 'vietnamese': 'Tiếng Anh'},
    'ja': {'native': '日本語', 'vietnamese': 'Tiếng Nhật'},
    'ko': {'native': '한국어', 'vietnamese': 'Tiếng Hàn'},
    'th': {'native': 'ภาษาไทย', 'vietnamese': 'Tiếng Thái'},
  };

  LocaleProvider() {
    _loadLanguage(_locale.languageCode);
  }

  Future<void> _loadLanguage(String langCode) async {
    _isLoaded = false;
    notifyListeners();
    
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$langCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedValues = jsonMap;
    } catch (e) {
      print("Lỗi tải ngôn ngữ $langCode: $e");
      // Fallback
      if (langCode != 'en') {
        try {
          String fallback = await rootBundle.loadString('assets/lang/en.json');
          _localizedValues = json.decode(fallback);
        } catch (_) {
          _localizedValues = {};
        }
      } else {
        _localizedValues = {};
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  String getText(String key, {Map<String, String>? params}) {
    String text = _localizedValues[key.trim()] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  void setLocale(String langCode) {
    if (supportedLocales.containsKey(langCode) && _locale.languageCode != langCode) {
      _locale = Locale(langCode);
      _loadLanguage(langCode);
    }
  }

  String get currentLanguageNativeName {
    return supportedLocales[_locale.languageCode]?['native'] ?? 'Tiếng Việt';
  }
}