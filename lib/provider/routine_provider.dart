import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../service/routine_service.dart';
import '../theme/app_icon.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineService _routineService = RoutineService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DateTime _selectedDate = DateTime.now();
  List<dynamic> _routines = [];
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<dynamic> get routines => _routines;
  bool get isLoading => _isLoading;

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  // 🚀 선택된 날짜를 바꾸고 해당 날짜의 루틴을 백엔드에서 가져옴
  Future<void> changeDateAndFetch(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners(); // 로딩 시작 알림

    try {
      final token = await _getToken();
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      _routines = await _routineService.getRoutinesByDate(token, dateString);
    } catch (e) {
      debugPrint('루틴 로딩 에러: $e');
      // 서버 통신 실패 시 화면 테스트를 위해 보여줄 임시 더미 데이터
      _routines = [
        {
          'id': 998,
          'title': '물 2L 마시기 (더미)',
          'icon_id': 20, // 20번: 물방울 아이콘
          'alarm_time': '09:00:00',
          'is_completed': false,
        },
        {
          'id': 999,
          'title': '스쿼트 100개 (더미)',
          'icon_id': 2, // 2번: 헬스 아령 아이콘
          'alarm_time': '19:30:00',
          'is_completed': true, // 이미 체크된 상태 테스트용
        }
      ];
    } finally {
      _isLoading = false;
      notifyListeners(); // 완료 알림 (화면 갱신)
    }
  }

  // 🚀 새 루틴 추가하기 (모델에 맞게 파라미터 원복)
  Future<void> addRoutine(
    int userId, String title, IconData icon, 
    List<String> daysOfWeek, String alarmTime
  ) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    if (mappedIconId == 0) mappedIconId = 20;

    final routineData = {
      "userId": userId,
      "title": title,
      "iconId": mappedIconId,
      "daysOfWeek": daysOfWeek.join(','),
      "alarmTime": "$alarmTime:00", // "09:00" -> "09:00:00" 포맷 맞춤
      "isActive": true
    };

    await _routineService.createRoutine(token, routineData);
    await changeDateAndFetch(_selectedDate);
  }

  // 🚀 루틴 삭제 로직
  Future<void> deleteRoutine(int routineId) async {
    final token = await _getToken();
    await _routineService.deleteRoutine(token, routineId);
    await changeDateAndFetch(_selectedDate); // 삭제 후 화면 새로고침
  }

  // 🚀 루틴 완료 체크 (화면 깜빡임 해결 - 낙관적 업데이트 적용)
  Future<void> toggleRoutineCheck(int routineId) async {
    // 1. 서버 응답을 기다리지 않고 내 폰 화면의 체크 표시부터 즉시 바꿈!
    final index = _routines.indexWhere((r) => r['id'] == routineId);
    if (index != -1) {
      final currentStatus = _routines[index]['is_completed'] ?? _routines[index]['isCompleted'] ?? false;
      _routines[index]['is_completed'] = !currentStatus;
      _routines[index]['isCompleted'] = !currentStatus;
      notifyListeners();
    }

    // 2. 서버에는 뒤에서 조용히 체크했다고 알려줌
    try {
      final token = await _getToken();
      // 🚀 현재 Provider가 들고 있는 달력 날짜를 String으로 변환해서 같이 보냄!
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate); 
      await _routineService.checkRoutine(token, routineId, dateString);
    } catch (e) {
      debugPrint('루틴 체크 서버 통신 에러: $e');
    }
  }

  // 🚀 루틴 수정하기
  Future<void> updateRoutine(
    int routineId, int userId, String title, IconData icon, 
    List<String> daysOfWeek, String alarmTime
  ) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    if (mappedIconId == 0) mappedIconId = 20;

    final routineData = {
      "userId": userId,
      "title": title,
      "iconId": mappedIconId,
      "daysOfWeek": daysOfWeek.join(','),
      "alarmTime": "$alarmTime:00",
      "isActive": true
    };

    await _routineService.updateRoutine(token, routineId, routineData);
    await changeDateAndFetch(_selectedDate); 
  }
}