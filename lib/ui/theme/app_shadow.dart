import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  // 💡 앱 전체에서 공통으로 쓸 그림자 속성!
  static List<BoxShadow> getPlushShadow(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        blurRadius: 8, // 🚨 아키텍처 규칙: blurRadius 8 고정
        offset: const Offset(0, 4),
      ),
    ];
  }
      
  // 필요하다면 나중에 다른 종류의 그림자도 여기에 추가
  // static List<BoxShadow> get hardShadow => [ ... ];
}