import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFAF6F0); // 따뜻한 상아색
  static const Color cardWhite = Color(0xFFFFFFFF);  // 카드 배경
  static const Color primary = Color(0xFFC49A70);    // 쿼카 브라운
  static const Color accent = Color(0xFF8EAC8C);     // 세이지 그린
  static const Color textMain = Color(0xFF3E2723);   // 모카 블랙
  static const Color textSub = Color(0xFF8D7B68);    // 토프 그레이
  static const Color border = Color(0xFFE6DED5);     // 연한 테두리
  static const Color icon = Color(0xFF7A6A5C);       // 아이콘 색상

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      spreadRadius: 0,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}