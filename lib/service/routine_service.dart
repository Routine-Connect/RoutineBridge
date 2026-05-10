import 'dart:convert';
import 'package:http/http.dart' as http;

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

      return responseData['data'] ?? {};
    } else {
      throw Exception('월간 데이터를 불러오지 못했습니다.');
    }
  } catch (e) {
    throw Exception('서버 연결 실패: $e');
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
        throw Exception(responseData['error']?['message'] ?? '루틴 생성에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
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
      if (response.statusCode != 200) throw Exception('루틴 수정에 실패했습니다.');
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // DELETE /api/routines/{id} - 루틴 삭제
  Future<void> deleteRoutine(String token, int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(url, 
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) throw Exception('루틴 삭제에 실패했습니다.');
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // POST /api/routines/{id}/check?date={date} - 루틴 완료 체크
  Future<void> checkRoutine(String token, int id, String date) async {
    try {
      final url = Uri.parse('$baseUrl/$id/check?date=$date');
      final response = await http.post(url, 
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) throw Exception('루틴 체크에 실패했습니다.');
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }
}