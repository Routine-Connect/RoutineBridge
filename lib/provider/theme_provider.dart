import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  DodayThemeType _currentTheme = DodayThemeType.milkTea;

  DodayThemeType get currentThemeType => _currentTheme;
  
  // 🚀 현재 테마의 색상을 반환하는 Getter (UI에서 이거만 부르면 됨)
  DodayThemeColors get colors => AppColors.themes[_currentTheme]!;

  ThemeProvider() {
    _loadTheme();
  }

  // 테마 변경 및 저장
  Future<void> setTheme(DodayThemeType type) async {
    _currentTheme = type;
    await _storage.write(key: 'app_theme', value: type.name);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: 'app_theme');
    if (saved != null) {
      _currentTheme = DodayThemeType.values.firstWhere((e) => e.name == saved);
      notifyListeners();
    }
  }
}