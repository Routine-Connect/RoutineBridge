import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    
    final now = DateTime.now();
    final targetMonth = _currentMonth;
    
    int daysToCalculate = 0;
    
    // 1. 기준일(분모)을 정확히 잡습니다.
    if (targetMonth.year == now.year && targetMonth.month == now.month) {
      // 📍 이번 달을 보고 있다면: 1일부터 '오늘'까지만 계산
      daysToCalculate = now.day;
    } else if (targetMonth.isBefore(now)) {
      // 📍 과거의 달을 보고 있다면: 그 달의 '마지막 날(전체 일수)'로 계산
      daysToCalculate = DateUtils.getDaysInMonth(targetMonth.year, targetMonth.month);
    } else {
      // 📍 미래의 달은 아직 안 왔으니 0%
      return 0;
    }

    if (daysToCalculate == 0) return 0;

    double total = 0;

    // 2. 1일부터 기준일까지 강제로 하루하루 돌면서 퍼센트를 싹 더합니다.
    for (int i = 1; i <= daysToCalculate; i++) {
      // 날짜 키 만들기 (예: "2024-05-01")
      // 패키지 누락 시 상단에 import 'package:intl/intl.dart'; 추가
      String dateKey = DateFormat('yyyy-MM-dd').format(DateTime(targetMonth.year, targetMonth.month, i));
      
      // 🚀 핵심: 백엔드가 데이터를 안 줬으면(체크 안 했으면) 0.0%로 깔아버림!
      total += _monthlyStats[dateKey] ?? 0.0;
    }

    // 3. 총 퍼센트 합 / 지나온 날짜 수
    return (total / daysToCalculate).round();
  }

  // 🚀 [가벼운 통신] 홈/마이페이지 숫자 전용 업데이트 (0.1초)
  Future<void> loadSummaryOnly() async {
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      final summary = await _statisticsService.fetchSummaryStats(token);
      
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

  // 🚀 로그아웃 시 이전 유저의 통계 데이터 완벽 삭제
  void clearStats() {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalCompleted = 0;
    _weeklyStats.clear();
    _monthlyStats.clear();
    _isDirty = true;
    _isFetching = false;
    notifyListeners();
  }
}