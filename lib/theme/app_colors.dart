import 'package:flutter/material.dart';

/// Doday 프로젝트 공통 디자인 시스템 (부드럽고 따뜻한 밀크/파스텔 톤으로 리팩토링)
abstract final class AppColors {
  // —— Material 3 토큰 (전체적으로 한 톤 밝고 부드럽게 조정) ——
  static const Color primary = Color(0xFFDCAE87); // 카라멜 -> 부드러운 밀크티 색상으로
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFBF1E6); // 훨씬 밝고 따뜻한 연베이지
  static const Color onPrimaryContainer = Color(0xFF5A4D43); // 덜 대비되게 부드러운 고동색
  static const Color primaryFixed = Color(0xFFFBF1E6);
  static const Color onPrimaryFixed = Color(0xFF5A4D43);
  static const Color onPrimaryFixedVariant = Color(0xFF82544A);
  static const Color primaryFixedDim = Color(0xFFFFCBBF);
  static const Color inversePrimary = Color(0xFFFFCBBF);

  static const Color secondary = Color(0xFF9E8C7D); // 진한 회갈색 -> 따뜻하고 연한 회갈색
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEBEAEA);
  static const Color onSecondaryContainer = Color(0xFF757575);
  static const Color secondaryFixed = Color(0xFFEBEAEA);
  static const Color secondaryFixedDim = Color(0xFFD6D6D6);
  static const Color onSecondaryFixed = Color(0xFF2C2E2E);
  static const Color onSecondaryFixedVariant = Color(0xFF5A5C5C);

  static const Color tertiary = Color(0xFF458577); // 진한 녹색 -> 부드러운 세이지 그린
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB5E8D9);
  static const Color onTertiaryContainer = Color(0xFF266D5E);
  static const Color tertiaryFixed = Color(0xFFCCF2E6);
  static const Color tertiaryFixedDim = Color(0xFFB5E8D9);
  static const Color onTertiaryFixed = Color(0xFF003028);
  static const Color onTertiaryFixedVariant = Color(0xFF166859);

  // 에러/경고 색상도 눈 아프지 않게 파스텔 코랄/레드로 변경
  static const Color error = Color(0xFFE57373); 
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFFC62828);

  static const Color background = Color(0xFFFEFDFB); // 거의 흰색에 가까운 아주 연한 크림색
  static const Color onBackground = Color(0xFF5A4D43);
  static const Color surface = Color(0xFFFEFDFB);
  static const Color onSurface = Color(0xFF5A4D43);
  static const Color surfaceVariant = Color(0xFFEFECE9);
  static const Color onSurfaceVariant = Color(0xFF9E8C7D);
  static const Color surfaceTint = Color(0xFFDCAE87);
  static const Color surfaceDim = Color(0xFFE8E5E2);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFAF7F5);
  static const Color surfaceContainer = Color(0xFFF5F1EE);
  static const Color surfaceContainerHigh = Color(0xFFEFECE9);
  static const Color surfaceContainerHighest = Color(0xFFE8E5E2);
  static const Color inverseSurface = Color(0xFF3E3C3A);
  static const Color inverseOnSurface = Color(0xFFF9F6F4);

  static const Color outline = Color(0xFFA3918E); // 테두리도 너무 진하지 않게
  static const Color outlineVariant = Color(0xFFEADBE8);

  // —— 🚀 [신규 추가] UI 디테일 전용 색상 ——
  static const Color dividerFaint = Color(0xFFE8E4E1); // 앱바, 하단바 밋밋함 방지용 아주 연한 구분선 색상
  static const Color swipeEdit = Color(0xFF93C5FD); // 스와이프 '수정' 배경 (파스텔 블루)
  static const Color swipeDelete = Color(0xFFFCA5A5); // 스와이프 '삭제' 배경 (파스텔 코랄 레드)

  // —— 🚀 [신규 추가] 향후 20개 아이콘 개별 테마에 쓰일 부드러운 파스텔톤 ——
  static const Color iconPastelRed = Color(0xFFFFCDD2);
  static const Color iconPastelOrange = Color(0xFFFFE0B2);
  static const Color iconPastelYellow = Color(0xFFFFF9C4);
  static const Color iconPastelGreen = Color(0xFFC8E6C9);
  static const Color iconPastelBlue = Color(0xFFBBDEFB);
  static const Color iconPastelPurple = Color(0xFFE1BEE7);
  static const Color iconPastelPink = Color(0xFFF8BBD0);

  // —— 리포트 시안 추가 브랜드 토큰 ——
  static const Color brandCaramel = Color(0xFFDCAE87);
  static const Color brandBeige = Color(0xFFFBF1E6);
  static const Color coralAccent = Color(0xFFFFCBBF);

  // —— 홈 루틴 카드 등 인라인 색 ——
  static const Color routineIconBrown = Color(0xFFA67C52);
  static const Color routineCardGreenTint = Color(0xFFF1F8F1);
  static const Color routineCardBlueTint = Color(0xFFEEF6FC);
  
  // —— 마이페이지 시안 포인트 ——
  static const Color streakOrange = Color(0xFFFF9800);
  static const Color logoutCoral = Color(0xFFEF5350);

  // —— 성취도 리포트 그리드 ——
  static const Color statYellowLight = Color(0xFFFEF9C3);
  static const Color statYellowDark = Color(0xFFCA8A04);
  static const Color statSkyLight = Color(0xFFE0F2FE);
  static const Color statSkyDark = Color(0xFF0EA5E9);

  // —— 다크 모드 참조 ——
  static const Color darkNavBar = Color(0xFF1C1917);
  static const Color darkNavHover = Color(0xFF292524);
  static const Color darkMutedText = Color(0xFFA8A29E);
}