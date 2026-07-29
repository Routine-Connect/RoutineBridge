import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../util/api_error_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = '${dotenv.env['BASE_URL']}';
  final _storage = const FlutterSecureStorage();

  // POST /api/users/login - 로그인
  Future<String> fetchLoginToken(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/login');
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
      final url = Uri.parse('$baseUrl/api/users/signup');
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

  // POST /api/auth/kakao - 카카오 로그인
  Future<Map<String, dynamic>> loginWithKakao(String kakaoAccessToken) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/kakao');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': kakaoAccessToken,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // 🚀 [핵심 수정] 받아온 JSON 데이터의 모든 Key와 Value를 쪼개서 상세하게 출력하기
      debugPrint("=============================================");
      debugPrint("📡 [JSON 분석] 백엔드 응답 데이터 상세 출력:");
      if (responseData is Map) {
        responseData.forEach((key, value) {
          debugPrint("🔑 Key: $key  ➡️  Value: $value");
          // 만약 내부 데이터(data나 error)가 중첩된 구조(Map)라면 안의 내용도 출력
          if (value is Map) {
            value.forEach((subKey, subValue) {
              debugPrint("   ↳ 📂 [$key 내부] Key: $subKey ➡️ Value: $subValue");
            });
          }
        });
      } else {
        debugPrint("Raw Body: ${response.body}");
      }
      debugPrint("=============================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
      
        debugPrint("🔑 카카오 로그인 성공! JWT 발급 완료: ${responseData['data']}");
        return responseData; 
      } 
      
      // 상태 코드가 200/201이 아니면 에러 핸들러로 던짐
      ApiErrorHandler.throwApiError(responseData, '카카오 로그인에 실패했습니다.');
      throw Exception('카카오 로그인 에러'); // (Dart 컴파일러를 위한 껍데기 에러)

    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
      rethrow; // loginWithKakao는 리턴 타입이 Map이라서 여기서 반드시 rethrow를 해줘야 에러가 안 남
    }
  }
}
