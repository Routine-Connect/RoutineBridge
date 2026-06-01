import 'package:flutter/material.dart';
import '../ui/widget/custom_snackbar.dart';

class ApiErrorHandler {
  static String messageFromBody(Map<String, dynamic> body, String fallback) =>
      body['error']?['message'] as String? ?? fallback;

  static Never throwApiError(Map<String, dynamic> body, String fallback) {
    throw Exception(messageFromBody(body, fallback));
  }

  static Never rethrowIfApiException(Object e) {
    if (e is Exception) throw e;
    throw Exception('서버와 연결할 수 없습니다.');
  }

  /// API 호출을 감싸서 안전하게 실행하고, 실패 시 스낵바를 띄워주는 함수
  static Future<void> execute(
    BuildContext context, 
    Future<void> Function() action, {
    VoidCallback? onSuccess, 
  }) async {
    try {
      await action();
      
      if (onSuccess != null && context.mounted) {
        onSuccess();
      }
    } catch (e) {
      if (!context.mounted) return;
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      CustomSnackBar.show(
        context, 
        message: errorMessage, 
        isError: true,
      );
    }
  }
}