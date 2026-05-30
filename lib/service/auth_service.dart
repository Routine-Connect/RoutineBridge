import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 서버 기본 주소
  final String baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/users';
  final _storage = const FlutterSecureStorage(); // 스토리지 인스턴스 생성

  // POST /api/users/login - 로그인
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
      // 이미 Exception인 경우 그대로 던지고, 아니면 네트워크 에러로 처리
      if (e is Exception) rethrow; 
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // POST /api/users/signup - 회원가입
  Future<void> signup(String email, String password, String nickname, String gender) async {
    try {
      final url = Uri.parse('$baseUrl/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // 💡 누락되었던 nickname 추가, Char 대신 String으로 gender 전송
        body: jsonEncode({
          'email': email, 
          'password': password, 
          'nickname': nickname, 
          'gender': gender 
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // 백엔드가 Void를 반환하므로 토큰을 뽑을 필요 없이 성공(200) 여부만 체크합니다.
      if (response.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['error']?['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // 로그아웃 (토큰 삭제)
  Future<void> logout() async {
    try {
      // 저장된 JWT 토큰을 기기에서 삭제합니다.
      await _storage.delete(key: 'jwt_token'); // 저장할 때 쓴 키(key) 이름과 동일하게 맞춰주세요.
    } catch (e) {
      throw Exception('로그아웃 처리 중 문제가 발생했습니다.');
    }
  }
}