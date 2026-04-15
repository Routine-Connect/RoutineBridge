import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 24),
          _MonthlySummaryCard(),
          SizedBox(height: 24),
          _StatsGrid(),
          SizedBox(height: 24),
          _RoutineCalendar(),
          SizedBox(height: 24),
          _ShareStreakCard(),
          // 🚨 하단 네비게이션 바 플로팅 영역 확보용 여백 (필수)
          SizedBox(height: 180),
        ],
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACHIEVEMENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '이번 달 성취도 85%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimaryContainer,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '지난달보다 12% 더 성장했어요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 탐정 쿼카 이미지 영역
              SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  'assets/images/quokka_manager.webp', // 🚨 탐정 쿼카 이미지 에셋 매핑 필요
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 프로그레스 바 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85, // 85% 달성
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.statYellowLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppColors.statYellowDark,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '최장 연속 일수',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '18일',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.statSkyLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: AppColors.statSkyDark,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '가장 성실한 루틴',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '아침 물 마시기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutineCalendar extends StatelessWidget {
  const _RoutineCalendar();

  @override
  Widget build(BuildContext context) {
    // 요일 라벨
    final List<String> weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    
    // 시안과 동일한 4월 목업 데이터 배열 
    // 0: 빈칸, 1: 완료(동그라미), 2: 부분완료(세모), 3: 미완료(표시없음)
    final List<int> aprilData = [
      0, 1, 2, 1, 3, 1, 1, // 1주차 (1일이 월요일)
      2, 1, 1, 1, 2, 1, 3, // 2주차
      1, 1, 1, 1, 1, 1, 1, // 3주차
      1, 1, 1, 3, 3, 3, 3, // 4주차
      3, 3, 3              // 5주차
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primaryContainer, width: 4),
              ),
            ),
            child: const Text(
              '4월 Routine',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: day == 'SUN' ? AppColors.logoutCoral : AppColors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // 달력 그리드
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aprilData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 4,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              if (aprilData[index] == 0) return const SizedBox(); // 빈 칸
              
              int dayNumber = index; // 1일이 index 1이므로 숫자 그대로 사용
              bool isSunday = index % 7 == 0;
              
              return _DayCell(
                day: dayNumber.toString(),
                status: aprilData[index],
                isSunday: isSunday,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String day;
  final int status; // 1: 동그라미, 2: 세모, 3: 없음
  final bool isSunday;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isSunday,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 날짜 텍스트
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSunday ? AppColors.logoutCoral : AppColors.onSurface,
          ),
        ),

        if (status == 1)
          Image.asset(
            'assets/images/circle.webp', // 동그라미 이미지
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          )
        else if (status == 2)
          Image.asset(
            'assets/images/triangle.webp', // 세모 이미지
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
      ],
    );
  }
}

class _ShareStreakCard extends StatelessWidget {
  const _ShareStreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        children: [
          const Text(
            '12일째 성공 중!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '12 DAY STREAK',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.onPrimaryContainer,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(999),
                child: const Center(
                  child: Text(
                    '나의 기록 공유하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}