import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../service/routine_service.dart';
import '../ui/theme/app_icon.dart';
import '../ui/widget/custom_snackbar.dart';
import 'statistics_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../service/notification_service.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineService _routineService = RoutineService();
  final NotificationService _notificationService = NotificationService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _lastCheeredDateKey = ''; 

  DateTime _selectedDate = DateTime.now();
  
  // 🚀 [에러 해결 핵심] 현재 화면에 보여줄 루틴 리스트 변수 선언
  List<dynamic> _routines = []; 
  
  // 🚀 월별 데이터 캐시 창고
  Map<String, Map<String, List<dynamic>>> _monthlyCache = {};
  
  bool _isLoading = false;

  // Getter들
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  Map<String, Map<String, List<dynamic>>> get monthlyCache => _monthlyCache;
  
  // 🚀 [수정] 이제 변수 _routines를 그대로 반환합니다.
  List<dynamic> get routines => _routines;

  // 🚀 [추가] 캐시 창고와 현재 선택된 날짜의 리스트를 동기화하는 내부 함수
  void _updateCurrentRoutines() {
    String monthKey = DateFormat('yyyy-MM').format(_selectedDate);
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // 캐시에서 가져오되, 없으면 빈 리스트를 넣어줌
    _routines = _monthlyCache[monthKey]?[dateKey] ?? [];
    notifyListeners();
  }

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  // 앱 시작 시 3개월치 데이터 가져오기
  Future<void> initMonthlyData() async {
    _isLoading = true;
    notifyListeners();
    DateTime now = DateTime.now();
    try {
      await Future.wait([
        fetchMonthData(DateTime(now.year, now.month - 1)), 
        fetchMonthData(now),                               
        fetchMonthData(DateTime(now.year, now.month + 1)), 
      ]);
      // 데이터 로드 후 현재 날짜 리스트 업데이트
      _updateCurrentRoutines(); 
    } catch (e) {
      debugPrint('초기 데이터 로딩 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 월간 데이터 fetch
  Future<void> fetchMonthData(DateTime date) async {
    String monthKey = DateFormat('yyyy-MM').format(date);
    if (_monthlyCache.containsKey(monthKey)) return;

    try {
      final token = await _getToken();
      final Map<String, dynamic> response = await _routineService.getMonthlyRoutines(token, date.year, date.month);
      final Map<String, dynamic> dailyData = response['daily'] ?? response['data']?['daily'] ?? {};

      // 백엔드에서 날아온 데이터 그대로 출력
      debugPrint('🚨 [$monthKey] 백엔드 응답 쌩데이터:');
      debugPrint(jsonEncode(dailyData));

      _monthlyCache[monthKey] = dailyData.map(
        (key, value) => MapEntry(key, List<dynamic>.from(value))
      );
      
      // 만약 방금 가져온 달이 현재 선택된 날짜와 같은 달이라면 화면 갱신
      if (DateFormat('yyyy-MM').format(_selectedDate) == monthKey) {
        _updateCurrentRoutines();
      }
      
      debugPrint('✅ $monthKey 캐시 로드 성공!');
    } catch (e) {
      debugPrint('❌ $monthKey 데이터 로드 실패: $e');
    }
  }

  // 날짜 클릭 시 (정상 범위)
  void changeDateAndFetch(DateTime date) {
    _selectedDate = date;
    _updateCurrentRoutines(); // 🚀 날짜가 바뀌었으니 리스트 동기화
    fetchMonthData(date);
  }

  // 루틴 체크 토글
  Future<void> toggleRoutineCheck(BuildContext context, int routineId) async {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // 현재 리스트에서 해당 루틴 찾기
    final index = _routines.indexWhere((r) => r['id'] == routineId);
    if (index == -1) return;

    bool currentStatus = _routines[index]['is_completed'] ?? _routines[index]['isCompleted'] ?? false;
    bool hasOtherCompleted = _routines.any((r) => 
         r['id'] != routineId && (r['is_completed'] ?? r['isCompleted'] ?? false) == true
    );

    // 1. 낙관적 업데이트 (변수와 캐시 둘 다 수정)
    _routines[index]['is_completed'] = !currentStatus;
    _routines[index]['isCompleted'] = !currentStatus; 
    notifyListeners();

    if (context.mounted) {
      context.read<StatisticsProvider>().markAsDirty();
    }

    // 쿼카 응원 로직
    if (!currentStatus && !hasOtherCompleted && _lastCheeredDateKey != dateKey) {
      if (context.mounted) CustomSnackBar.showCheer(context);
      _lastCheeredDateKey = dateKey; 
    }

    try {
      final token = await _getToken();
      await _routineService.checkRoutine(token, routineId, dateKey);
    } catch (e) {
      // 실패 시 롤백
      _routines[index]['is_completed'] = currentStatus; 
      _routines[index]['isCompleted'] = currentStatus; 
      notifyListeners();
      if (context.mounted) {
        context.read<StatisticsProvider>().markAsDirty();
        CustomSnackBar.show(context, message: '네트워크 에러로 체크가 취소되었습니다.', isError: true);
      }
    }
  }

  // 데이터 갱신 후 리스트 업데이트를 위한 헬퍼
  Future<void> _refreshAllData() async {
    _monthlyCache.clear();
    await initMonthlyData();
    _updateCurrentRoutines(); 

    // 💡 현재 정렬되어 캐싱된 오늘의 루틴 목록을 순회하며 폰 스케줄러에 알림 등록/취소 진행!
    // 마이페이지의 '전체 앱 알림 켜기' 스토리지 값까지 함께 분기 처리해 주면 완벽해.
    final String? globalNotiRaw = await _storage.read(key: 'isRoutineNotiEnabled');
    bool isGlobalNotiEnabled = globalNotiRaw == null ? true : (globalNotiRaw == 'true');

    for (var routine in _routines) {
      int id = routine['id'];
      String title = routine['title'] ?? '';
      String time = routine['alarmTime'] ?? routine['alarm_time'] ?? '09:00:00';
      
      // 스네이크/카멜 케이스 양방향 방어 및 null인 경우 false 처리
      bool isAlarmEnabled = routine['isAlarmEnabled'] ?? routine['is_alarm_enabled'] ?? false;

      // 🚀 앱 전체 알림이 켜져 있고 + 해당 루틴 푸시(isAlarmEnabled)도 켜져 있을 때만 실제 알림 예약!
      if (isGlobalNotiEnabled && isAlarmEnabled) {
        await _notificationService.scheduleDailyRoutineNotification(
          routineId: id,
          title: title,
          alarmTime: time,
        );
      } else {
        // 둘 중 하나라도 꺼져 있으면 기기 예약 알림 파기
        await _notificationService.cancelNotification(id);
      }
    }
  }

  // 추가/삭제/수정 로직은 동일... (생략하되 내부에서 _refreshAllData 호출 유지)
  Future<void> addRoutine(int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime, bool isAlarmEnabled) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = { "userId": userId, "title": title, "iconId": mappedIconId == 0 ? 20 : mappedIconId, "daysOfWeek": daysOfWeek.join(','), "alarmTime": "$alarmTime:00", "isActive": true, "isAlarmEnabled": isAlarmEnabled, };
    await _routineService.createRoutine(token, routineData);
    await _refreshAllData();
  }

  Future<void> deleteRoutine(int routineId) async {
    final token = await _getToken();
    await _notificationService.cancelNotification(routineId);
    await _routineService.deleteRoutine(token, routineId);
    await _refreshAllData();
  }

  Future<void> updateRoutine(int routineId, int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime, bool isAlarmEnabled) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = { "userId": userId, "title": title, "iconId": mappedIconId == 0 ? 20 : mappedIconId, "daysOfWeek": daysOfWeek.join(','), "alarmTime": "$alarmTime:00", "isActive": true, "isAlarmEnabled": isAlarmEnabled, };
    await _routineService.updateRoutine(token, routineId, routineData);
    await _refreshAllData();
  }

  List<dynamic> _originalRoutines = []; // 드래그 시작 시점의 원본
  bool _isReordering = false;
  bool _hasChanges = false; // 🚀 변경이 일어났는지 추적

  bool get isReordering => _isReordering;
  bool get hasChanges => _hasChanges;

  // 드래그 시작 시 원본 저장
  void setReordering(bool value, List<dynamic> currentList) {
    _isReordering = value;
    if (value) {
      _originalRoutines = List.from(currentList);
      _hasChanges = false; // 시작할 땐 변경 없음
    }
    notifyListeners();
  }

  // 리스트 순서 변경 시마다 변경 여부 체크
  void updateLocalRoutines(List<dynamic> newList) {
    _routines = newList;
    
    // 원본과 비교 (ID 순서로 비교)
    final originalIds = _originalRoutines.map((e) => e['id']).toList();
    final newIds = newList.map((e) => e['id']).toList();
    
    // 순서가 다르면 true, 같으면 false
    _hasChanges = originalIds.join(',') != newIds.join(',');
    notifyListeners();
  }

  // 순서 저장 API
  Future<void> saveRoutineOrder(List<dynamic> updatedRoutines) async {
    print("🚀 [API 통신] 순서 저장 요청 시작...");
    final token = await _storage.read(key: 'jwt_token') ?? '';
    
    final List<Map<String, dynamic>> orderData = updatedRoutines.asMap().entries.map((entry) {
      return {
        "id": entry.value['id'] ?? entry.value['routineId'],
        "sortOrder": entry.key + 1,
      };
    }).toList();

    try {
      // 1. 서버에 순서 변경 요청
      await _routineService.updateOrder(token, orderData);
      print("✅ [API 통신] 순서 저장 API 호출 성공!");

      // 2. [캐시 갱신 로직]
      await _refreshAllData();

      // 3. 상태 초기화 (버튼 원상복구)
      _isReordering = false;
      _hasChanges = false;
      _originalRoutines = [];
      
      notifyListeners();
      print("✅ 로컬 상태 초기화 완료 (순서 저장 버튼 다시 추가하기로 복귀)");

    } catch (e) {
      print("❌ [API 통신] 순서 저장 실패: $e");
      
      // 실패 시에도 버튼은 원래대로 돌려줘야 유저가 다시 시도 가능
      _isReordering = false;
      notifyListeners();
    }
  }

  void clearRoutines() {
    _monthlyCache.clear();
    _routines = [];
    notifyListeners();
  }
}