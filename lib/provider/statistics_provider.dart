import 'package:flutter/material.dart';
import '../service/statistics_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. 요약 데이터 (스트릭, 총 완료 개수)
  int _currentStreak = 0;  // 통계 페이지에서 띄울 숫자 데이터 
  int _totalCompleted = 0; // 마이페이지에서 띄울 숫자 데이터
  int _longestStreak = 0; // 마이페이지에 띄울 최장 기록
  
  // 2. 그래프 및 달력 데이터
  Map<String, double> _weeklyStats = {};
  Map<String, double> _monthlyStats = {}; 
  DateTime _currentMonth = DateTime.now(); 
  
  bool _isDirty = true;    // 전체 데이터 갱신 필요 여부
  bool _isFetching = false; // 중복 통신 방지용 자물쇠
  bool get isLoading => _isFetching;

  int get currentStreak => _currentStreak;
  int get totalCompleted => _totalCompleted;
  int get longestStreak => _longestStreak;
  Map<String, double> get weeklyStats => _weeklyStats;
  Map<String, double> get monthlyStats => _monthlyStats;
  DateTime get currentMonth => _currentMonth;

  // 더티 플래그 마킹 (홈에서 루틴 체크 시 호출)
  void markAsDirty() {
    _isDirty = true;
  }

  // 이번 달 평균 성취도 계산 로직
  int get monthlyAchievementRate {
    if (_monthlyStats.isEmpty) return 0;
    double total = 0;
    int count = 0;
    final today = DateUtils.dateOnly(DateTime.now());
    _monthlyStats.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      if (!date.isAfter(today)) {
        total += value;
        count++;
      }
    });
    return count == 0 ? 0 : (total / count).round();
  }

  // 🚀 [가벼운 통신] 홈/마이페이지 숫자 전용 업데이트 (0.1초)
  Future<void> loadSummaryOnly() async {
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      final summary = await _statisticsService.fetchSummaryStats(token);
      
      // 💡 [디버그 추가] 백엔드가 진짜로 뭐라고 주는지 터미널에 출력해봅니다!
      debugPrint('🔥 [디버그] 요약 API 응답 데이터: $summary');

      // 백엔드 Postman 응답 키값에 정확히 매핑
      _currentStreak = summary['currentStreak'] ?? 0;
      _totalCompleted = summary['totalCompleted'] ?? 0;
      _longestStreak = summary['longestStreak'] ?? 0;
      
      notifyListeners(); // 숫자 즉시 반영
    } catch (e) {
      debugPrint('요약 통계 로드 에러: $e');
    }
  }

  // 🚀 [무거운 통신] 통계 탭 전체 데이터 업데이트 (Dirty Flag + SWR)
  Future<void> loadFullStats() async {
    if (!_isDirty || _isFetching) return;
    _isFetching = true;

    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      final weeklyFuture = _statisticsService.fetchWeeklyStats(token);
      final monthlyFuture = _statisticsService.fetchMonthlyStats(token, _currentMonth.year, _currentMonth.month);

      await Future.wait([weeklyFuture, monthlyFuture]);

      final rawWeekly = await weeklyFuture;
      final rawMonthly = await monthlyFuture;

      _weeklyStats = rawWeekly.map((key, value) => MapEntry(key, value.toDouble()));
      _monthlyStats = rawMonthly.map((key, value) => MapEntry(key, value.toDouble()));

      _isDirty = false;
    } catch (e) {
      debugPrint('전체 통계 데이터 로드 에러: $e');
    } finally {
      _isFetching = false;
      notifyListeners(); // 에러 나도 멈춤 방지를 위해 호출
    }
  }
}