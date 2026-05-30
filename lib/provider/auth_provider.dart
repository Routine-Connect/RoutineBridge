import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService(); // 💡 통신 담당 택배기사 고용!
  
  String? _token; 

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // 앱 켤 때 토큰 불러오기
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'jwt_token');
    notifyListeners(); 
  }

  // 🚀 화면(UI)에서 호출하는 로그인 로직
  Future<String?> login(String email, String password) async {
    try {
      // 1. Service에게 통신 심부름 시켜서 토큰 받아오기
      final String fetchedToken = await _authService.fetchLoginToken(email, password);
      
      // 2. 받아온 토큰을 메모리와 금고에 저장
      _token = fetchedToken; 
      await _storage.write(key: 'jwt_token', value: _token); 
      
      notifyListeners(); // 3. 화면 갱신 방송
      return null; // 성공했으므로 에러 메시지는 null 반환
      
    } catch (e) {
      rethrow; // 에러는 화면에서 처리하도록 던져줍니다.
    }
  }

  // 로그아웃 로직
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}