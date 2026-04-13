import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 서버 기본 주소
  final String baseUrl = 'http://10.0.2.2:8080/api/users';

  // 🚀 로그인 API 통신
  Future<String> fetchLoginToken(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login'); 
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        // 성공 시 토큰(String)만 쏙 뽑아서 반환
        return responseData['data']; 
      } else {
        // 실패 시 백엔드가 보낸 에러 메시지를 에러로 던짐(throw)
        throw Exception(responseData['error']?['message'] ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      // 서버가 꺼져있거나 인터넷이 끊긴 경우
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }
}