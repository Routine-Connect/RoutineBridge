import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../service/routine_service.dart';
import '../theme/app_icon.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineService _routineService = RoutineService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DateTime _selectedDate = DateTime.now();
  
  // 🚀 핵심: 월별 데이터 캐시 창고 
  // 구조: { "2024-04": { "2024-04-20": [루틴들], "2024-04-21": [...] } }
  Map<String, Map<String, List<dynamic>>> _monthlyCache = {};
  
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // 🚀 Getter: 캐시 창고 자체를 반환 (달력 스탬프 계산용)
  Map<String, Map<String, List<dynamic>>> get monthlyCache => _monthlyCache;

  // 🚀 Getter: 현재 선택된 날짜의 루틴 리스트를 캐시에서 즉시 추출
  List<dynamic> get routines {
    String monthKey = DateFormat('yyyy-MM').format(_selectedDate);
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _monthlyCache[monthKey]?[dateKey] ?? [];
  }

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  // 🚀 [신규] 앱 시작 시 호출: 전달, 이번 달, 다음 달 3개월치 한꺼번에 가져오기
  Future<void> initMonthlyData() async {
    _isLoading = true;
    notifyListeners();

    DateTime now = DateTime.now();
    try {
      // Future.wait를 사용해 3개의 API를 병렬로 호출 (속도 최적화)
      await Future.wait([
        fetchMonthData(DateTime(now.year, now.month - 1)), // 전달
        fetchMonthData(now),                              // 이번 달
        fetchMonthData(DateTime(now.year, now.month + 1)), // 다음 달
      ]);
    } catch (e) {
      debugPrint('초기 데이터 로딩 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 [신규] 특정 월의 데이터를 서버에서 가져와 캐시에 저장
  Future<void> fetchMonthData(DateTime date) async {
    String monthKey = DateFormat('yyyy-MM').format(date);
    
    // 이미 캐시에 있으면 중복 호출 방지
    if (_monthlyCache.containsKey(monthKey)) return;

    try {
      final token = await _getToken();
      // 백엔드: GET /api/routines/monthly-daily?year=yyyy&month=m
      final Map<String, dynamic> data = await _routineService.getMonthlyRoutines(
        token, 
        date.year, 
        date.month
      );

      // 받아온 데이터를 Map<String, List<dynamic>> 형태로 변환하여 저장
      _monthlyCache[monthKey] = data.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
      notifyListeners();
    } catch (e) {
      debugPrint('$monthKey 데이터 로드 실패: $e');
    }
  }

  // 🚀 날짜 클릭 시: 이제 서버 통신 없이 날짜만 바꿈 (UX 향상)
  void changeDateAndFetch(DateTime date) {
    _selectedDate = date;
    notifyListeners(); 
    
    // 혹시라도 이동한 달의 데이터가 없으면 백그라운드에서 조용히 가져옴
    fetchMonthData(date);
  }

  // 🚀 루틴 완료 체크 (낙관적 업데이트)
  Future<void> toggleRoutineCheck(int routineId) async {
    String monthKey = DateFormat('yyyy-MM').format(_selectedDate);
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final dayRoutines = _monthlyCache[monthKey]?[dateKey];
    if (dayRoutines == null) return;

    final index = dayRoutines.indexWhere((r) => r['id'] == routineId);
    
    if (index != -1) {
      // 1. 서버 응답 전 내 창고 데이터부터 즉시 수정 (체크박스 & 달력 스탬프 동시 반응)
      bool currentStatus = dayRoutines[index]['is_completed'] ?? dayRoutines[index]['isCompleted'] ?? false;
      dayRoutines[index]['is_completed'] = !currentStatus;
      dayRoutines[index]['isCompleted'] = !currentStatus; 
      notifyListeners();

      // 2. 서버에는 뒤에서 조용히 보고
      try {
        final token = await _getToken();
        await _routineService.checkRoutine(token, routineId, dateKey);
      } catch (e) {
        // 실패 시 다시 원래대로 복구하는 로직 (선택 사항)
        debugPrint('루틴 체크 에러: $e');
      }
    }
  }

  // 🚀 [수정됨] 루틴 추가/삭제/수정 후에는 전체 캐시를 싹 비우고 3개월치를 다시 세팅합니다!
  Future<void> _refreshAllData() async {
    _monthlyCache.clear(); // 1. 창고 완전 초기화
    await initMonthlyData(); // 2. 최신 기준으로 전달/이번달/다음달 다시 가져오기
  }

  Future<void> addRoutine(int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = {
      "userId": userId,
      "title": title,
      "iconId": mappedIconId == 0 ? 20 : mappedIconId,
      "daysOfWeek": daysOfWeek.join(','),
      "alarmTime": "$alarmTime:00",
      "isActive": true
    };
    await _routineService.createRoutine(token, routineData);
    await _refreshAllData(); // 🔄 전체 캐시 갱신!
  }

  Future<void> deleteRoutine(int routineId) async {
    final token = await _getToken();
    await _routineService.deleteRoutine(token, routineId);
    await _refreshAllData(); // 🔄 전체 캐시 갱신!
  }

  Future<void> updateRoutine(int routineId, int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = {
      "userId": userId,
      "title": title,
      "iconId": mappedIconId == 0 ? 20 : mappedIconId,
      "daysOfWeek": daysOfWeek.join(','),
      "alarmTime": "$alarmTime:00",
      "isActive": true
    };
    await _routineService.updateRoutine(token, routineId, routineData);
    await _refreshAllData(); // 🔄 전체 캐시 갱신!
  }
}