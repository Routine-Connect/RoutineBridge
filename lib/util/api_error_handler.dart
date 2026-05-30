import 'package:flutter/material.dart';
import '../ui/widget/custom_snackbar.dart';

class ApiErrorHandler {
  /// 🚀 API 호출을 감싸서 안전하게 실행하고, 실패 시 스낵바를 띄워주는 함수
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