import 'dart:convert';
import 'package:http/http.dart' as http;

class StatisticsService {
  final String _baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/stats';

  // GET /api/stats/streak/all - 가입일 기준 전체 기간 요약 통계 (마이페이지용)
  Future<Map<String, dynamic>> getAllTimeStreak(String token) async {
    final url = Uri.parse('$_baseUrl/streak/all');
    final response = await http.get(
      url, 
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      // 백엔드 응답 포맷에 맞춰 데이터 파싱 처리
      return decoded['data'] ?? decoded;
    } else {
      throw Exception('전체 기간 스트릭 통계를 불러오지 못했습니다.');
    }
  }

  // GET /api/stats/streak - 상단 요약 통계 (스트릭 + 총 완료 개수 한 번에 가져오기)
  Future<Map<String, dynamic>> fetchSummaryStats(String token) async {
    final url = Uri.parse('$_baseUrl/streak'); 
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded['data'] ?? decoded;
    } else {
      throw Exception('통계 요약을 불러오지 못했습니다.');
    }
  }

  // GET /api/stats/weekly - 주간 통계 (그래프용)
  Future<Map<String, double>> fetchWeeklyStats(String token) async {
    final url = Uri.parse('$_baseUrl/weekly'); // URL 중복 수정 완료
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final daily = decoded['data']['daily'] as Map<String, dynamic>;
      
      // JSON의 값을 Map<String, double>로 깔끔하게 캐스팅
      return daily.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } else {
      throw Exception('주간 통계를 불러오지 못했습니다.');
    }
  }

  // GET /api/stats/monthly?year=yyyy&month=m - 월간 통계 (달력 스탬프용)
  Future<Map<String, dynamic>> fetchMonthlyStats(String token, int year, int month) async {
    final url = Uri.parse('$_baseUrl/monthly?year=$year&month=$month'); 
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      
      final data = decoded['data'] ?? decoded;
      
      // 1. 일별 달성률 데이터 추출
      final dailyRaw = data['daily'] as Map<String, dynamic>? ?? {};
      final Map<String, double> dailyStats = dailyRaw.map(
        (key, value) => MapEntry(key, (value as num).toDouble())
      );

      // 2. 🚀 백엔드에서 새로 추가된 '총 개수'와 '완료 개수' 추출
      final int totalCount = data['totalRoutineCount'] ?? 0;
      final int completedCount = data['completedRoutineCount'] ?? 0;

        return {
        'daily': dailyStats,
        'totalRoutineCount': data['totalRoutineCount'] ?? 0,
        'completedRoutineCount': data['completedRoutineCount'] ?? 0,
      };
    } else {
      throw Exception('월간 통계를 불러오지 못했습니다.');
    }
  }
}