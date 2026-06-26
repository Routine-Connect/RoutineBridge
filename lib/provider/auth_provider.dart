import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/auth_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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

  // 🚀 카카오 로그인 버튼을 눌렀을 때 실행되는 함수
  Future<String> loginWithKakao() async {
    try {
      OAuthToken token;
      
      // 1. 📱 폰에 카카오톡 앱이 깔려있으면 카카오톡으로, 없으면 웹뷰로 띄움
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final responseData = await _authService.loginWithKakao(token.accessToken);
      
      // 🔐 [수정 핵심] responseData['data'] 내부에서 'token' 글자를 정확히 꺼내옵니다.
      if (responseData['data'] != null && responseData['data']['token'] != null) {
         final String jwtToken = responseData['data']['token']; // 👈 Map 내부의 토큰 문자열 추출
         
         _token = jwtToken; // 메모리에 저장
         await _storage.write(key: 'jwt_token', value: jwtToken); // 👈 이제 확실한 String이 들어가므로 무죄!
      }

      // 🚀 백엔드가 새로 추가해 준 진짜 'isNewUser' 플래그 데이터를 매핑합니다.
      // responseData['data']['isNewUser'] 경로로 째려봐야 합니다.
      bool isNewUser = false;
      if (responseData['data'] != null && responseData['data']['isNewUser'] != null) {
        isNewUser = responseData['data']['isNewUser'] == true;
      }
      
      return isNewUser ? 'NEW_USER' : 'EXISTING_USER';

    } catch (e) {
      throw Exception('카카오 로그인 중 오류 발생: $e');
    }
  }

  // 로그아웃 로직
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}