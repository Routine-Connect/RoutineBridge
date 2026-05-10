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

  // 🚀 [추가] 이번 달 총 루틴 개수와 완료 개수를 담을 바구니
  int _monthlyTotalCount = 0;
  int _monthlyCompletedCount = 0;

  // 🚀 [추가] 외부에서 읽을 수 있게 Getter 열어주기
  int get monthlyTotalCount => _monthlyTotalCount;
  int get monthlyCompletedCount => _monthlyCompletedCount;

  // 더티 플래그 마킹 (홈에서 루틴 체크 시 호출)
  void markAsDirty() {
    _isDirty = true;
  }

  // 🚀 [수정] 복잡한 계산 루프 삭제! 백엔드가 준 데이터로 즉시 계산
  int get monthlyAchievementRate {
    if (_monthlyTotalCount == 0) return 0;
    
    // (완료 / 전체) * 100 한 뒤 반올림하여 정수로 반환
    return ((_monthlyCompletedCount / _monthlyTotalCount) * 100).round();
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

  // 🚀 [수정] 전체 통계 데이터 업데이트 로직
  Future<void> loadFullStats() async {
    if (!_isDirty || _isFetching) return;
    _isFetching = true;

    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      // 1. 서비스 호출
      final weeklyData = await _statisticsService.fetchWeeklyStats(token);
      final monthlyData = await _statisticsService.fetchMonthlyStats(token, _currentMonth.year, _currentMonth.month);

      // 2. 주간 데이터 반영
      _weeklyStats = weeklyData.map((key, value) => MapEntry(key, value.toDouble()));

      // 3. 🚀 월간 데이터 & 백엔드 요약 숫자 반영
      // monthlyData['daily']가 null일 경우를 대비해 빈 Map 처리
      _monthlyStats = (monthlyData['daily'] as Map<String, double>?) ?? {};


      _monthlyTotalCount = monthlyData['totalRoutineCount'] ?? 0;
      _monthlyCompletedCount = monthlyData['completedRoutineCount'] ?? 0;

      // 로그를 찍어서 데이터가 들어오는지 직접 확인해보세요!
      debugPrint('📊 로드된 총 개수: $_monthlyTotalCount, 완료 개수: $_monthlyCompletedCount');

      _isDirty = false;
    } catch (e) {
      debugPrint('❌ 전체 통계 데이터 로드 에러: $e');
    } finally {
      _isFetching = false;
      notifyListeners(); 
    }
  }

  // 🚀 [수정] 로그아웃 시 새로운 변수들도 초기화
  void clearStats() {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalCompleted = 0;
    _monthlyTotalCount = 0;      // 추가
    _monthlyCompletedCount = 0;  // 추가
    _weeklyStats.clear();
    _monthlyStats.clear();
    _isDirty = true;
    _isFetching = false;
    notifyListeners();
  }
}