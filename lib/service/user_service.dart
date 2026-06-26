import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/user.dart';
import '../model/NotificationSettings.dart';
import '../util/api_error_handler.dart';

class UserService {
  final String baseUrl = 'https://nonextendible-kandace-gratifyingly.ngrok-free.dev/api/users';
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
        ApiErrorHandler.throwApiError(responseData, '정보를 불러오지 못했습니다.');
      }
    } catch (e) {
      debugPrint('유저 정보 조회 실패: $e');
      ApiErrorHandler.rethrowIfApiException(e);
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
        ApiErrorHandler.throwApiError(responseData, '프로필 수정에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
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
        ApiErrorHandler.throwApiError(responseData, '이미지 업로드에 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // PATCH /api/users/me/gender - 성별 설정
  Future<void> updateGender(String token, String gender) async {
    try {
      final url = Uri.parse('$baseUrl/me/gender'); // 백엔드 주소에 맞게 확인!
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'gender': gender, // 'M' 또는 'F'
        }),
      );

      // 204(No Content) 성공일 때는 바디가 없어서 jsonDecode 하면 앱 터짐 방어 코드 추가
      if (response.statusCode == 204) return;

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // 상태 코드가 200이 아니거나, 백엔드 응답의 success 플래그가 false일 때
      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '성별 설정에 실패했습니다.');
      }
    } catch (e) {
      // 발생한 에러가 우리가 만든 ApiException이면 화면단으로 넘겨서 스낵바 띄우게 함
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }
  // GET /api/users/me/notifications - 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final url = Uri.parse('$baseUrl/me/notifications');
      final token = await _secureStorage.read(key: 'jwt_token');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("🔔 [GET 알림 설정] 상태코드: ${response.statusCode}");
      debugPrint("🔔 [GET 알림 설정] 응답 바디: ${response.body}");

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        final Map<String, dynamic> realData = responseData['data'] ?? responseData;
        return NotificationSettings.fromJson(realData);
      } else {
        ApiErrorHandler.throwApiError(responseData, '알림 설정을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }

  // PUT /api/users/me/notifications - 알림 설정 저장하기
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
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

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || responseData['success'] != true) {
        ApiErrorHandler.throwApiError(responseData, '알림 설정을 업데이트하는데 실패했습니다.');
      }
    } catch (e) {
      ApiErrorHandler.rethrowIfApiException(e);
    }
  }
}
