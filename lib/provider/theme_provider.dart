import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../ui/theme/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  DodayThemeType _currentTheme = DodayThemeType.milkTea;

  DodayThemeType get currentThemeType => _currentTheme;
  
  // 🚀 현재 테마의 색상을 반환하는 Getter
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

  // 앱 시작 시 저장된 테마 불러오기
  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: 'app_theme');
    if (saved != null) {
      _currentTheme = DodayThemeType.values.firstWhere((e) => e.name == saved);
      notifyListeners();
    }
  }

  // 테마 적용
  ThemeData get themeData {
    return ThemeData(
      fontFamily: 'Pretendard',
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowest, 
      colorScheme: ColorScheme.light(
        primary: colors.primary, // 선택한 테마의 메인 컬러
        primaryContainer: colors.primaryContainer, // 선택한 테마의 연한 배경 컬러
        surface: AppColors.surfaceContainerLowest, // 앱 기본 배경색
      ),
    );
  }

  // 테마 초기화 (로그아웃 시 호출)
  void clearTheme() {
    _currentTheme = DodayThemeType.milkTea; // 기본 테마로 초기화
    notifyListeners();
  }
}