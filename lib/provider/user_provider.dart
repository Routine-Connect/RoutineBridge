import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../model/NotificationSettings.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  // 생성자에 User 정보 가져오는 로직추가
  UserProvider() {
    loadMyProfile(); 
  }

  // 토큰 불러오기
  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

 // 🚀 2. 실제 백엔드에서 유저 정보를 가져오는 로직
  Future<void> loadMyProfile() async {
    try {
      // 1. 스토리지에서 JWT 토큰 꺼내기
      final token = await _getToken();
      
      // 2. 서비스에 토큰을 넘겨주고 프로필 조회 로직 실행
      final fetchedUser = await _userService.getMyProfile(token);
      
      // 3. 유저 정보를 메모리에 저장
      _currentUser = fetchedUser;
      
      // 4. 화면 갱신
      notifyListeners();
    } catch (e) {
      // 토큰이 없거나 만료된 경우 (로그인 안 된 상태)
      _currentUser = null;
      debugPrint('유저 정보 로딩 실패: $e'); // 임의 데이터 대신 에러만 조용히 남김
    }
  }

  // 🚀 1. 닉네임 변경
  Future<void> updateNickname(String newNickname) async {
    if (_currentUser == null) return;
    final token = await _getToken();
    await _userService.updateProfile(token, newNickname, null);
    
    _currentUser = _currentUser!.copyWith(nickname: newNickname);
    notifyListeners(); 
  }

  // 🚀 2. 비밀번호 변경 (비밀번호는 화면 상태가 없으므로 통신만 처리)
  Future<void> updatePassword(String newPassword) async {
    final token = await _getToken();
    await _userService.updateProfile(token, null, newPassword);
  }

  // 🚀 3. 프로필 이미지 변경
  Future<void> updateProfileImage(File imageFile) async {
    if (_currentUser == null) return;
    final token = await _getToken();
    
    // 서버에 업로드 후 새 이미지 URL 받아오기
    final newImageUrl = await _userService.uploadProfileImage(token, imageFile);
    
    // 화면 정보 갱신
    _currentUser = _currentUser!.copyWith(profileImage: newImageUrl);
    notifyListeners();
  }

  // 🚀 4. 알림 상태 변경
  NotificationSettings? _notificationSettings;
  NotificationSettings? get notificationSettings => _notificationSettings;

  // 바텀 시트를 열 때 호출할 함수 (서버에서 설정값 불러오기)
  Future<void> loadNotificationSettings() async {
    try {
      _notificationSettings = await _userService.getNotificationSettings();
      notifyListeners();
    } catch (e) {
      debugPrint("알림 설정 로드 실패: $e");
    }
  }

  // 스위치를 껐다 켤 때 호출할 함수 (화면 먼저 바꾸고 서버로 전송)
  Future<void> updateNotification(NotificationSettings newSettings) async {
    // 1. 화면 스위치를 즉시 바꿈 (버벅임 방지)
    _notificationSettings = newSettings;
    notifyListeners();
    
    try {
      // 2. 백엔드 서버에 변경값 전송
      await _userService.updateNotificationSettings(newSettings);
    } catch (e) {
       debugPrint("알림 설정 업데이트 실패: $e");
       // 3. 실패하면 서버에서 원래 데이터를 다시 가져와서 원상복구
       await loadNotificationSettings(); 
    }
  }
}