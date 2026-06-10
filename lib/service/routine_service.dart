import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/api_error_handler.dart';

class RoutineService {
  final String baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/routines';

  // GET /api/routines/monthly-daily?year=yyyy&month=m
  Future<Map<String, dynamic>> getMonthlyRoutines(String token, int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/monthly-daily?year=$year&month=$month');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData['success'] == true) {
        Map<String, dynamic> data = responseData['data'] ?? {};

        data.forEach((date, routinesList) {
          if (routinesList is List) {
            routinesList.sort((a, b) {
              int orderA = a['sortOrder'] ?? a['sort_order'] ?? 0;
              int orderB = b['sortOrder'] ?? b['sort_order'] ?? 0;

              if (orderA != orderB) {
                return orderA.compareTo(orderB);
              }

              int idA = a['id'] ?? 0;
              int idB = b['id'] ?? 0;
              return idA.compareTo(idB);
            });
          }
        });
        return data;
      } else {
        ApiErrorHandler.throwApiError(responseData, '월간 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // POST /api/routines - 루틴 생성
  Future<void> createRoutine(String token, Map<String, dynamic> routineData) async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(routineData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '루틴 생성에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // PUT /api/routines/{id} - 루틴 수정
  Future<void> updateRoutine(String token, int id, Map<String, dynamic> routineData) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.put(url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(routineData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '루틴 수정에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // DELETE /api/routines/{id} - 루틴 삭제
  Future<void> deleteRoutine(String token, int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '루틴 삭제에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // PUT /api/routines/order - 루틴 순서 저장
  Future<void> updateOrder(String token, List<Map<String, dynamic>> orderData) async {
    try {
      final url = Uri.parse('$baseUrl/order');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '순서 저장에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // POST /api/routines/{id}/check?date={date} - 루틴 완료 체크
  Future<void> checkRoutine(String token, int id, String date) async {
    try {
      final url = Uri.parse('$baseUrl/$id/check?date=$date');
      final response = await http.post(url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '루틴 체크에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // PATCH /api/routines/{id}/alarm - 알림 상태 단독 변경
  Future<void> patchRoutineAlarm(String token, int routineId, bool isAlarmEnabled, String? alarmTime) async {
    try {
      final url = Uri.parse('$baseUrl/$routineId/alarm');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isAlarmEnabled': isAlarmEnabled,  // 👈 대소문자 주의!
          if (alarmTime != null) 'alarmTime': alarmTime, // 👈 대소문자 주의!
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || responseData['success'] != true) {
        // 🚀 어제 만든 에러 핸들러로 백엔드 에러 메시지 캡처!
        ApiErrorHandler.throwApiError(responseData, '알림 상태 변경에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }
}
