import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'app_colors.dart';

class AppIcons {
  // 🚀 기획된 최종 루틴 아이콘 20선 (Phosphor 'Regular' 스타일로 명시!)
  static const List<IconData> routineIcons = [
    PhosphorIconsRegular.sparkle,      // 1. 기타/나만의 루틴
    PhosphorIconsRegular.drop,         // 2. 물 마시기
    PhosphorIconsRegular.pill,         // 3. 영양제/알약
    PhosphorIconsRegular.bowlFood,     // 4. 식사 챙겨 먹기
    PhosphorIconsRegular.personSimple,  // 5. 요가/스트레칭
    PhosphorIconsRegular.barbell,      // 6. 헬스/근력 운동
    PhosphorIconsRegular.sneaker,      // 7. 러닝/산책
    PhosphorIconsRegular.sprayBottle,  // 8. 스킨케어/팩
    PhosphorIconsRegular.bookOpen,     // 9. 독서/책 읽기
    PhosphorIconsRegular.notePencil,   // 10. 일기 쓰기/공부/기록
    PhosphorIconsRegular.monitor,       // 11. 코딩/노트북 업무
    PhosphorIconsRegular.piggyBank,      // 12. 가계부/지출 점검
    PhosphorIconsRegular.sunHorizon,   // 13. 기상하기/미라클 모닝
    PhosphorIconsRegular.moonStars,    // 14. 취침하기/밤 루틴
    PhosphorIconsRegular.bed,          // 15. 침구 정리
    PhosphorIconsRegular.broom,        // 16. 청소하기/환기
    PhosphorIconsRegular.pawPrint,     // 17. 펫 케어
    PhosphorIconsRegular.headphones,   // 18. 음악 연습/감상
    PhosphorIconsRegular.palette,      // 19. 미술 연습/드로잉
    PhosphorIconsRegular.tote,         // 20. 쇼핑/마트
  ];

  // 🚀 배경색: 모두 연베이지 (수정 없음)
  static List<Color> getRoutineIconBackgroundColors(BuildContext context) {
    return List.generate(
      20, (index) => Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
    );
  }
  

  // 🚀 전경색: 기획에 맞춘 찰떡 미드톤 컬러 매핑 (수정 없음)
  static const List<Color> routineIconForegroundColors = [
    AppColors.iconMidYellow, // 1. sparkle
    AppColors.iconMidSky,    // 2. drop
    AppColors.iconMidPink,   // 3. pill
    AppColors.iconMidOrange, // 4. bowlFood
    AppColors.iconMidGreen,  // 5. flowerLotus
    AppColors.iconMidBrown,  // 6. barbell
    AppColors.iconMidSky,    // 7. sneaker
    AppColors.iconMidPink,   // 8. sprayBottle
    AppColors.iconMidYellow, // 9. bookOpen
    AppColors.iconMidPurple, // 10. pencilLine
    AppColors.iconMidBrown,  // 11. laptop
    AppColors.iconMidGreen,  // 12. receipt
    AppColors.iconMidOrange, // 13. sunHorizon
    AppColors.iconMidPurple, // 14. moonStars
    AppColors.iconMidPurple, // 15. bed
    AppColors.iconMidSky,    // 16. broom
    AppColors.iconMidOrange, // 17. pawPrint
    AppColors.iconMidOrange, // 18. headphones
    AppColors.iconMidRed,    // 19. palette
    AppColors.iconMidRed,    // 20. tote
  ];
}