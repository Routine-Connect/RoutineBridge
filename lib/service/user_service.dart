import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🚀 스토리지 임포트!

import '../model/user.dart';
import '../model/NotificationSettings.dart';

class UserService {
  final String baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/users';
  
  // 🚀 스토리지 객체(변수) 생성!
  final _secureStorage = const FlutterSecureStorage();

  // GET api/users/me - 프로필 정보 조회
  Future<User> getMyProfile(String token) async {
    try {
      final url = Uri.parse('$baseUrl/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('👤 유저 정보 응답 상태코드: ${response.statusCode}');
      debugPrint('👤 유저 정보 응답 바디: ${response.body}');

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        return User.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['error']?['message'] ?? '정보를 불러오지 못했습니다.');
      }
    } catch (e) {
      debugPrint('유저 정보 조회 실패: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // POST api/users/me - 프로필 정보 수정
  Future<void> updateProfile(String token, String? nickname, String? password) async {
    try {
      final url = Uri.parse('$baseUrl/me');
      
      final Map<String, dynamic> bodyData = {};
      if (nickname != null) bodyData['nickname'] = nickname;
      if (password != null) bodyData['password'] = password;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode(bodyData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['error']?['message'] ?? '프로필 수정에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // POST api/users/me/image - 프로필 이미지 업로드
  Future<String> uploadProfileImage(String token, File imageFile) async {
    try {
      final url = Uri.parse('$baseUrl/me/image');
      var request = http.MultipartRequest('POST', url);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      var multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data']; 
      } else {
        throw Exception(responseData['error']?['message'] ?? '이미지 업로드에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // GET /api/users/me/notifications - 알림 설정 가져오기 
  Future<NotificationSettings> getNotificationSettings() async {
    final url = Uri.parse('$baseUrl/me/notifications');
    final token = await _secureStorage.read(key: 'jwt_token');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint("🔔 [GET 알림 설정] 상태코드: ${response.statusCode}");
    debugPrint("🔔 [GET 알림 설정] 응답 바디: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      
      final Map<String, dynamic> realData = decoded['data'] ?? decoded; 
      
      return NotificationSettings.fromJson(realData);
    } else {
      throw Exception('알림 설정을 불러오는데 실패했습니다.');
    }
  }

  // PUT /api/users/me/notifications - 알림 설정 저장하기 
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    final url = Uri.parse('$baseUrl/me/notifications');
    final token = await _secureStorage.read(key: 'jwt_token');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(settings.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('알림 설정을 업데이트하는데 실패했습니다.');
    }
  }
}