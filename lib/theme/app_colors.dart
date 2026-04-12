import 'package:flutter/material.dart';

/// Stitch 프로젝트 `projects/13703795185962469143` 시안(홈·마이페이지·성취도 리포트)에서 추출한 색상.
abstract final class AppColors {
  // —— Material 3 토큰 (tailwind theme.extend.colors) ——
  static const Color primary = Color(0xFFD49A6A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF5E6D3);
  static const Color onPrimaryContainer = Color(0xFF4A3F35);
  static const Color primaryFixed = Color(0xFFF5E6D3);
  static const Color onPrimaryFixed = Color(0xFF4A3F35);
  static const Color onPrimaryFixedVariant = Color(0xFF6C382F);
  static const Color primaryFixedDim = Color(0xFFFEB4A6);
  static const Color inversePrimary = Color(0xFFFEB4A6);

  static const Color secondary = Color(0xFF877464);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0DFDF);
  static const Color onSecondaryContainer = Color(0xFF626363);
  static const Color secondaryFixed = Color(0xFFE3E2E2);
  static const Color secondaryFixedDim = Color(0xFFC6C6C6);
  static const Color onSecondaryFixed = Color(0xFF1A1C1C);
  static const Color onSecondaryFixedVariant = Color(0xFF464747);

  static const Color tertiary = Color(0xFF2D685C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF97D3C4);
  static const Color onTertiaryContainer = Color(0xFF1F5C51);
  static const Color tertiaryFixed = Color(0xFFB2EFDF);
  static const Color tertiaryFixedDim = Color(0xFF96D2C3);
  static const Color onTertiaryFixed = Color(0xFF00201A);
  static const Color onTertiaryFixedVariant = Color(0xFF0E5045);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFFDFBF7);
  static const Color onBackground = Color(0xFF4A3F35);
  static const Color surface = Color(0xFFFDFBF7);
  static const Color onSurface = Color(0xFF4A3F35);
  static const Color surfaceVariant = Color(0xFFE5E2E0);
  static const Color onSurfaceVariant = Color(0xFF877464);
  static const Color surfaceTint = Color(0xFFD49A6A);
  static const Color surfaceDim = Color(0xFFDDD9D7);
  static const Color surfaceBright = Color(0xFFFCF9F7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F3F1);
  static const Color surfaceContainer = Color(0xFFF1EDEB);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E5);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E0);
  static const Color inverseSurface = Color(0xFF31302F);
  static const Color inverseOnSurface = Color(0xFFF4F0EE);

  static const Color outline = Color(0xFF857370);
  static const Color outlineVariant = Color(0xFFD7C2BE);

  // —— 리포트 시안 추가 브랜드 토큰 ——
  static const Color brandCaramel = Color(0xFFD49A6A);
  static const Color brandBeige = Color(0xFFF5E6D3);
  static const Color coralAccent = Color(0xFFFFB5A7);

  // —— 홈 루틴 카드 등 인라인 색 ——
  static const Color routineIconBrown = Color(0xFF8B5A2B);
  static const Color routineCardGreenTint = Color(0xFFE8F5E9);
  static const Color routineCardBlueTint = Color(0xFFE3F2FD);
  static const Color plushShadow = Color(0x148B5A2B);

  // —— 마이페이지 시안 포인트 ——
  static const Color streakOrange = Color(0xFFFF8C00);
  static const Color logoutCoral = Color(0xFFEF5350);

  // —— 성취도 리포트 그리드 (Tailwind 유틸 대응) ——
  static const Color statYellowLight = Color(0xFFFEF9C3);
  static const Color statYellowDark = Color(0xFFCA8A04);
  static const Color statSkyLight = Color(0xFFE0F2FE);
  static const Color statSkyDark = Color(0xFF0EA5E9);

  // —— 다크 모드 참조 (시안 class="dark:bg-stone-*") ——
  static const Color darkNavBar = Color(0xFF1C1917);
  static const Color darkNavHover = Color(0xFF292524);
  static const Color darkMutedText = Color(0xFFA8A29E);
}
