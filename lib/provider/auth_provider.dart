import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  // 💡 1. 영구 저장소
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // 💡 2. 앱 실행 중 유지되는 메모리 (전역 변수)
  String? _token; 

  // 외부에서 내 토큰 상태를 읽을 수 있게 해주는 게터(Getter)
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // 🚀 앱 켤 때 딱 한 번 실행: 금고에서 토큰을 꺼내 메모리에 올림
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'jwt_token');
    notifyListeners(); // "내 상태가 변했으니 화면들 다 새로고침 해!" 라고 방송함
  }

  // 🚀 로그인 로직 (서버 통신 + 토큰 저장)
  // 성공하면 null 반환, 실패하면 에러 메시지(String) 반환
  Future<String?> login(String email, String password) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/users/login'); 
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        // 🎉 로그인 성공! 
        _token = responseData['data']; // 1. 메모리(주머니)에 넣고
        await _storage.write(key: 'jwt_token', value: _token); // 2. 금고에도 백업!
        
        notifyListeners(); // 화면 갱신 방송
        return null; // 에러 없음(성공)
      } else {
        // ❌ 로그인 실패 (백엔드가 준 에러 메시지 반환)
        return responseData['error']?['message'] ?? '로그인에 실패했습니다.';
      }
    } catch (e) {
      return '서버와 연결할 수 없습니다.';
    }
  }

  // 🚀 로그아웃 로직 (메모리와 금고 모두 비우기)
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}