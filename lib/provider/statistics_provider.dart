import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/statistics_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. 요약 데이터
  int _currentStreak = 0;  
  int _totalCompleted = 0; 
  int _longestStreak = 0; 
  
  // 2. 마이페이지 전체 스트릭 데이터
  Map<String, dynamic>? _allTimeStreak;

  // 3. 그래프 데이터
  Map<String, double> _weeklyStats = {};
  
  // 🚀 [핵심] 3개월치(또는 그 이상) 월간 데이터를 쟁여둘 캐시 창고
  // Key: 'yyyy-MM' (예: '2026-05')
  // Value: 해당 월의 통계 데이터 (daily, totalRoutineCount, completedRoutineCount)
  final Map<String, Map<String, dynamic>> _monthlyCache = {}; 
  
  DateTime _currentMonth = DateTime.now(); 
  
  bool _isDirty = true;    
  bool _isFetching = false; 
  bool get isLoading => _isFetching;

  // 🚀 1. 유저 가입일을 담아둘 변수
  DateTime? _userCreatedAt; 

  // 🚀 2. 외부(UI)에서 이 변수에 가입일을 넣어주는 세터 함수
  void setUserCreatedAt(DateTime createdAt) {
    _userCreatedAt = createdAt;
  }

  // 기본 Getter
  int get currentStreak => _currentStreak;
  int get totalCompleted => _totalCompleted;
  int get longestStreak => _longestStreak;
  Map<String, double> get weeklyStats => _weeklyStats;
  DateTime get currentMonth => _currentMonth;

  // 🚀 [추가] 현재 보고 있는 달(_currentMonth)의 데이터를 캐시에서 알아서 꺼내주는 Getter들
  Map<String, double> get monthlyStats {
    final monthKey = DateFormat('yyyy-MM').format(_currentMonth);
    return (_monthlyCache[monthKey]?['daily'] as Map<String, double>?) ?? {};
  }

  int get monthlyTotalCount {
    final monthKey = DateFormat('yyyy-MM').format(_currentMonth);
    return _monthlyCache[monthKey]?['totalRoutineCount'] ?? 0;
  }

  int get monthlyCompletedCount {
    final monthKey = DateFormat('yyyy-MM').format(_currentMonth);
    return _monthlyCache[monthKey]?['completedRoutineCount'] ?? 0;
  }

  // 이번 달 성취도 계산 (캐시에서 꺼낸 값을 바로 계산)
  int get monthlyAchievementRate {
    if (monthlyTotalCount == 0) return 0;
    return ((monthlyCompletedCount / monthlyTotalCount) * 100).round();
  }

  void markAsDirty() {
    _isDirty = true;
  }

  Map<String, dynamic>? get allTimeStreak => _allTimeStreak;
  bool get isDirty => _isDirty;

  // 가입일 기준 전체 기간 스트릭 로드 API 연동 - myPage에서 사용
  Future<void> loadAllTimeStreak() async {
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      // 💡 통신 레이어 호출 (StatisticsService에 구현 필수)
      _allTimeStreak = await _statisticsService.getAllTimeStreak(token);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 전체 스트릭 로드 에러: $e');
    }
  }

  // 🚀 [추가] 달력 월 변경 시 호출할 함수 (스와이프 시)
  void changeMonth(DateTime newMonth) {
    _currentMonth = newMonth;
    
    // 타겟 달, 이전 달, 다음 달 데이터를 캐시에 없으면 미리 가져옴 (Pre-fetch)
    _fetchMonthData(newMonth);
    _fetchMonthData(DateTime(newMonth.year, newMonth.month - 1, 1));
    _fetchMonthData(DateTime(newMonth.year, newMonth.month + 1, 1));
    
    notifyListeners(); // 화면 즉시 전환 (캐시에 있으면 딜레이 0초)
  }

  // 🚀 단일 월 통계 데이터 로드 (캐싱 로직) - forceRefresh 플래그 주입 가능하도록 확장
  Future<void> _fetchMonthData(DateTime date, {bool forceRefresh = false}) async {
    final monthKey = DateFormat('yyyy-MM').format(date);
    
    // 🚀 [수정] 강제 새로고침(forceRefresh)이 아닐 때만 기존 캐시를 신뢰하고 통신 차단
    if (!forceRefresh && _monthlyCache.containsKey(monthKey)) return;

    // _userCreatedAt을 사용해 과거 데이터 호출차단
    if (_userCreatedAt != null) {
      final targetMonth = DateTime(date.year, date.month, 1);
      final joinMonth = DateTime(_userCreatedAt!.year, _userCreatedAt!.month, 1);

      if (targetMonth.isAfter(currentMonth)) {
      debugPrint('⏳ $monthKey는 미래이므로 통계 API를 호출하지 않습니다.');
      return; 
    }
  }

    // 3. 🚀 [복구됨] 진짜 서버와 통신해서 데이터를 가져오는 로직!
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      // 백엔드 서비스 호출!
      final monthlyData = await _statisticsService.fetchMonthlyStats(token, date.year, date.month);

      // 이번엔 진짜 백엔드가 준 데이터를 까봅니다.
      debugPrint('📊 $monthKey 백엔드 진짜 원본 데이터: $monthlyData');

      // 캐시 창고에 예쁘게 포장해서 저장
      _monthlyCache[monthKey] = {
        'daily': monthlyData['daily'] as Map<String, double>? ?? {},
        'totalRoutineCount': monthlyData['totalRoutineCount'] ?? 0,
        'completedRoutineCount': monthlyData['completedRoutineCount'] ?? 0,
      };
      
      debugPrint('✅ $monthKey 캐시 로드 성공!');
      
    } catch (e) {
      debugPrint('❌ $monthKey 통계 데이터 로드 에러: $e');
    } finally {
      notifyListeners(); // 데이터가 들어왔으니 화면에 쏴줍니다!
    }
  }

  // 통계 페이지 하단 최근 스트릭 GET /api/stats/streak 에서 _currentStreak
  Future<void> loadSummaryOnly() async {
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      final summary = await _statisticsService.fetchSummaryStats(token);
      _currentStreak = summary['currentStreak'] ?? 0;

      debugPrint('✅ 요약 통계 로드 성공! 현재 스트릭: $_currentStreak, 총 완료: $_totalCompleted, 최장 스트릭: $_longestStreak');
      
      notifyListeners(); 
    } catch (e) {
      debugPrint('요약 통계 로드 에러: $e');
    }
  }



  // 🚀 [수정] 통계 탭 최초 진입 시, 주간 데이터와 함께 '3개월치'를 한 번에 긁어옵니다.
  Future<void> loadFullStats() async {
    if (!_isDirty || _isFetching) return;
    _isFetching = true;

    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      // 1. 주간 데이터
      final weeklyData = await _statisticsService.fetchWeeklyStats(token);
      _weeklyStats = weeklyData.map((key, value) => MapEntry(key, value.toDouble()));

      // 2. 🚀 월간 데이터 3개월치 병렬 로드 (현재, 이전, 다음 달) 
      // 더티 깃발이 올라간 상태이므로 forceRefresh: true를 주입해 캐시 방어막을 뚫고 최신화시킵니다.
      await Future.wait([
        _fetchMonthData(_currentMonth, forceRefresh: true),
        _fetchMonthData(DateTime(_currentMonth.year, _currentMonth.month - 1, 1), forceRefresh: true),
        _fetchMonthData(DateTime(_currentMonth.year, _currentMonth.month + 1, 1), forceRefresh: true),
      ]);

      // 🚀 통신이 끝났으므로 깃발을 내립니다. 다음번엔 탭 전환을 해도 무지성 API 낭비를 차단합니다.
      _isDirty = false;
      debugPrint('✅ 통계 3개월치 로드 완료 및 Dirty Flag 해제 완료!');
    } catch (e) {
      debugPrint('❌ 전체 통계 데이터 로드 에러: $e');
    } finally {
      _isFetching = false;
      notifyListeners(); 
    }
  }

  // 🚀 [신규 추가] 부분 업데이트 로직!
  // 홈 화면에서 루틴을 체크하거나 삭제했을 때, 백엔드 응답값을 받아 이 함수를 호출하세요.
  void updateMonthSummary(DateTime date, int newTotal, int newCompleted) {
    final monthKey = DateFormat('yyyy-MM').format(date);
    if (_monthlyCache.containsKey(monthKey)) {
      _monthlyCache[monthKey]!['totalRoutineCount'] = newTotal;
      _monthlyCache[monthKey]!['completedRoutineCount'] = newCompleted;
      notifyListeners(); // 퍼센트 바가 즉시 부드럽게 갱신됩니다!
    }
  }

  void clearStats() {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalCompleted = 0;
    _weeklyStats.clear();
    _monthlyCache.clear(); // 🚀 캐시 창고도 비워줌
    _currentMonth = DateTime.now();
    _isDirty = true;
    _isFetching = false;
    notifyListeners();
  }
}