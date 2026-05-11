import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../service/routine_service.dart';
import '../ui/theme/app_icon.dart';
import '../ui/widget/custom_snackbar.dart';
import 'statistics_provider.dart';
import 'package:provider/provider.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineService _routineService = RoutineService();
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

  // 🚀 [중요] 가입일 이전 날짜를 눌렀을 때 호출할 함수
  void setSelectedDateOnly(DateTime date) {
    _selectedDate = date;
    _routines = []; // 🚀 이제 _routines 변수가 존재하므로 에러 안 남! 확실하게 비워줌.
    notifyListeners();
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
  }

  // 추가/삭제/수정 로직은 동일... (생략하되 내부에서 _refreshAllData 호출 유지)
  Future<void> addRoutine(int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = { "userId": userId, "title": title, "iconId": mappedIconId == 0 ? 20 : mappedIconId, "daysOfWeek": daysOfWeek.join(','), "alarmTime": "$alarmTime:00", "isActive": true };
    await _routineService.createRoutine(token, routineData);
    await _refreshAllData();
  }

  Future<void> deleteRoutine(int routineId) async {
    final token = await _getToken();
    await _routineService.deleteRoutine(token, routineId);
    await _refreshAllData();
  }

  Future<void> updateRoutine(int routineId, int userId, String title, IconData icon, List<String> daysOfWeek, String alarmTime) async {
    final token = await _getToken();
    int mappedIconId = AppIcons.routineIcons.indexOf(icon) + 1;
    final routineData = { "userId": userId, "title": title, "iconId": mappedIconId == 0 ? 20 : mappedIconId, "daysOfWeek": daysOfWeek.join(','), "alarmTime": "$alarmTime:00", "isActive": true };
    await _routineService.updateRoutine(token, routineId, routineData);
    await _refreshAllData();
  }

  void clearRoutines() {
    _monthlyCache.clear();
    _routines = [];
    notifyListeners();
  }
}