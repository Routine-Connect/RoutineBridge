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
        CustomSnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  Future<void> _refreshAllData() async {
    _monthlyCache.clear();
    await initMonthlyData();
    _updateCurrentRoutines(); 

    final String? globalNotiRaw = await _storage.read(key: 'isRoutineNotiEnabled');
    bool isGlobalNotiEnabled = globalNotiRaw == null ? true : (globalNotiRaw == 'true');

    // 🚀 [디버깅 1] 마스터 스위치 상태 확인
    debugPrint("================[ 알림 엔진 검문소 ]================");
    debugPrint("🎛️ 두꺼비집(마스터 스위치) 상태: $isGlobalNotiEnabled (스토리지 원본: $globalNotiRaw)");

    for (var routine in _routines) {
      int id = routine['id'];
      String title = routine['title'] ?? '';
      String time = routine['alarmTime'] ?? routine['alarm_time'] ?? '09:00:00';
      
      // 🚀 [디버깅 2] 백엔드가 루틴 리스트 줄 때 개별 스위치 값을 잘 주는지 확인
      bool isAlarmEnabled = routine['isAlarmEnabled'] ?? routine['is_alarm_enabled'] ?? false;
      
      debugPrint("🔍 [루틴 ID: $id] 백엔드 원본 데이터: $routine");
      debugPrint("🔍 [루틴 ID: $id] 파싱된 개별 스위치 값: $isAlarmEnabled | 파싱된 시간: $time");

      if (isGlobalNotiEnabled && isAlarmEnabled) {
        await _notificationService.scheduleDailyRoutineNotification(
          routineId: id,
          title: title,
          alarmTime: time,
        );
      } else {
        await _notificationService.cancelNotification(id);
        debugPrint("⛔ [루틴 ID: $id] 알림 취소됨 사유 -> 마스터 켜짐?: $isGlobalNotiEnabled / 개별 켜짐?: $isAlarmEnabled");
      }
    }
    debugPrint("====================================================");
  }

  // 추가/삭제/수정 로직은 동일... (생략하되 내부에서 _refreshAllData 호출 유지)
  Future<void> addRoutine(int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime, bool isAlarmEnabled) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = { "userId": userId, "title": title, "iconId": mappedIconId == 0 ? 20 : mappedIconId, "daysOfWeek": daysOfWeek.join(','), "alarmTime": "$alarmTime:00", "isActive": true, "isAlarmEnabled": isAlarmEnabled, };
    
    debugPrint("================[ 📤 백엔드 전송 데이터 확인 ]================");
    debugPrint("🚀 [POST] /api/routines 에 보내는 원본 데이터:");
    debugPrint(jsonEncode(routineData));
    debugPrint("========================================================");
    
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

  // 🚀 [완벽 수정] 진짜 낙관적 업데이트가 적용된 알림 토글 함수
  Future<void> toggleRoutineAlarm(int routineId, bool isAlarmEnabled, String? alarmTime, Map<String, dynamic> routineRaw) async {
    // 💡 [롤백용 백업] 에러가 났을 때를 대비해 과거 상태를 기억해둠
    bool previousAlarmEnabled = false;
    String? previousAlarmTime;

    // =========================================================
    // 1. [진짜 낙관적 업데이트] 무조건 화면(UI)부터 즉시 바꾼다!!! ⚡️
    // =========================================================
    for (var monthKey in _monthlyCache.keys) {
      for (var dateKey in _monthlyCache[monthKey]!.keys) {
        final dailyList = _monthlyCache[monthKey]![dateKey]!;
        for (var i = 0; i < dailyList.length; i++) {
          if (dailyList[i]['id'] == routineId) {
            var item = dailyList[i];
            // 과거 상태 백업
            previousAlarmEnabled = dailyList[i]['isAlarmEnabled'] ?? dailyList[i]['is_alarm_enabled'] ?? false;
            previousAlarmTime = dailyList[i]['alarmTime'] ?? dailyList[i]['alarm_time'];

            // 새로운 상태 즉시 덮어쓰기
           item['isAlarmEnabled'] = item['is_alarm_enabled'] = isAlarmEnabled;
            if (alarmTime != null) {
              item['alarmTime'] = item['alarm_time'] = alarmTime;
            }
          }
        }
      }
    }
    
    _updateCurrentRoutines(); 
    notifyListeners(); // 🚀 유저는 버튼을 누르자마자 변경된 화면을 보게 됨! (딜레이 0초)

    // =========================================================
    // 2. 백그라운드 작업 (알림 스케줄러 동기화 & 백엔드 통신) 📡
    // =========================================================
    try {
      final token = await _getToken();

      // 로컬 스케줄러 즉시 동기화
      if (isAlarmEnabled && alarmTime != null) {
        await _notificationService.scheduleDailyRoutineNotification(
          routineId: routineId,
          title: routineRaw['title'] ?? '루틴',
          alarmTime: alarmTime,
        );
      } else {
        await _notificationService.cancelNotification(routineId);
      }

      // 서버에 변경 사항 몰래 전송 (유저는 이 시간을 체감하지 못함)
      await _routineService.patchRoutineAlarm(token, routineId, isAlarmEnabled, alarmTime);

    } catch (e) {
      // =========================================================
      // 3. [에러 복구] 서버 통신 실패 시 화면을 몰래 원상복구 (Rollback) 🛠️
      // =========================================================
      for (var monthKey in _monthlyCache.keys) {
        for (var dateKey in _monthlyCache[monthKey]!.keys) {
          final dailyList = _monthlyCache[monthKey]![dateKey]!;
          for (var i = 0; i < dailyList.length; i++) {
            if (dailyList[i]['id'] == routineId) {
              var item = dailyList[i]; // 변수로 빼기

              item['isAlarmEnabled'] = item['is_alarm_enabled'] = previousAlarmEnabled;
              if (previousAlarmTime != null) {
                item['alarmTime'] = item['alarm_time'] = previousAlarmTime;
              }
            }
          }
        }
      }
      _updateCurrentRoutines();
      notifyListeners(); // 🚨 실패했으므로 스위치를 다시 원래대로 돌려놓음
      
      // 스케줄러도 원상복구
      if (previousAlarmEnabled && previousAlarmTime != null) {
        await _notificationService.scheduleDailyRoutineNotification(
          routineId: routineId,
          title: routineRaw['title'] ?? '루틴',
          alarmTime: previousAlarmTime,
        );
      } else {
        await _notificationService.cancelNotification(routineId);
      }

      rethrow; // ApiErrorHandler가 에러 스낵바를 띄우도록 에러를 위로 던짐!
    }
  }

  void clearRoutines() {
    _monthlyCache.clear();
    _routines = [];
    notifyListeners();
  }
}