import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../util/api_error_handler.dart';

class AuthService {
  final String baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/users';
  final _storage = const FlutterSecureStorage();

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
        return responseData['data'];
      } else {
        ApiErrorHandler.throwApiError(responseData, '로그인에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // POST /api/users/signup - 회원가입
  Future<void> signup(String email, String password, String nickname, String gender) async {
    try {
      final url = Uri.parse('$baseUrl/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nickname': nickname,
          'gender': gender,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '회원가입에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // 로그아웃 (토큰 삭제)
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      throw Exception('로그아웃 처리 중 문제가 발생했습니다.');
    }
  }
}
