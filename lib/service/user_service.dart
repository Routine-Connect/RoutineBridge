import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'http://10.0.2.2:8080/api/users';

  // 🚀 프로필 수정 (닉네임, 비밀번호)
  Future<void> updateProfile(String token, String? nickname, String? password) async {
    try {
      final url = Uri.parse('$baseUrl/me');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // JWT 토큰 추가
        },
        body: jsonEncode({
          'nickname': nickname,
          'password': password,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['error']?['message'] ?? '프로필 수정에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // 🚀 프로필 이미지 업로드 (Multipart 데이터 통신)
  Future<String> uploadProfileImage(String token, File imageFile) async {
    try {
      final url = Uri.parse('$baseUrl/me/image');
      
      // 파일 전송을 위한 MultipartRequest 사용
      var request = http.MultipartRequest('POST', url);
      
      // 1. 헤더에 토큰 추가
      request.headers['Authorization'] = 'Bearer $token';
      
      // 2. 파일 추가 ('file' 파라미터명은 백엔드 @RequestParam("file")과 일치해야 함)
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // 3. 요청 전송 및 응답 대기
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data']; // 이미지 URL 반환
      } else {
        throw Exception(responseData['error']?['message'] ?? '이미지 업로드에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }
}