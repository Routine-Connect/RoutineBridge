import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/api_error_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatisticsService {
  final String baseUrl = '${dotenv.env['BASE_URL']}';

  // GET /api/stats/streak/all - 가입일 기준 전체 기간 요약 통계 (마이페이지용)
  Future<Map<String, dynamic>> getAllTimeStreak(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/stats/streak/all');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'] ?? responseData;
      } else {
        ApiErrorHandler.throwApiError(responseData, '전체 기간 스트릭 통계를 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // GET /api/stats/streak - 상단 요약 통계
  Future<Map<String, dynamic>> fetchSummaryStats(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/stats/streak');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'] ?? responseData;
      } else {
        ApiErrorHandler.throwApiError(responseData, '통계 요약을 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // GET /api/stats/weekly - 주간 통계 (그래프용)
  Future<Map<String, double>> fetchWeeklyStats(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/stats/weekly');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        final daily = responseData['data']['daily'] as Map<String, dynamic>;
        return daily.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else {
        ApiErrorHandler.throwApiError(responseData, '주간 통계를 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // GET /api/stats/monthly?year=yyyy&month=m - 월간 통계
  Future<Map<String, dynamic>> fetchMonthlyStats(String token, int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/api/stats/monthly?year=$year&month=$month');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'] ?? responseData;

        final dailyRaw = data['daily'] as Map<String, dynamic>? ?? {};
        final Map<String, double> dailyStats = dailyRaw.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );

        return {
          'daily': dailyStats,
          'totalRoutineCount': data['totalRoutineCount'] ?? 0,
          'completedRoutineCount': data['completedRoutineCount'] ?? 0,
        };
      } else {
        ApiErrorHandler.throwApiError(responseData, '월간 통계를 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // 🚀 GET /api/stats/share/token - 공유 토큰 및 URL 발급 (로그인 인증 필요)
  Future<Map<String, dynamic>> fetchShareToken(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/stats/share/token');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'] ?? responseData;
      } else {
        ApiErrorHandler.throwApiError(responseData, '공유 URL을 발급받지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // 🚀 GET /api/share/{token} - 공유 데이터 조회 (인증 없이 누구나 조회 가능)
  Future<Map<String, dynamic>> fetchSharedData(String shareToken) async {
    try {
      final url = Uri.parse('$baseUrl/api/share/$shareToken');

      final response = await http.get(url); // 인증 헤더 없음

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'] ?? responseData;
      } else {
        ApiErrorHandler.throwApiError(responseData, '공유 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }
}
