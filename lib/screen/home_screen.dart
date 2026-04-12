import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// 그림자의 반경(blurRadius)을 8로 최적화하여 그래픽 과부하를 막습니다.
List<BoxShadow> get _plushShadow => [
      BoxShadow(
        color: AppColors.plushShadow ?? Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _horizontalPadding = 24;
  static const double _sectionGap = 32;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          '오늘의 루틴',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      // [수정 핵심] 상단 고정 영역과 리스트 영역을 하나의 ListView로 통합하여 전체 스크롤 구현
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        // 스크롤 성능 향상을 위해 physics 추가
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 8), // AppBar 아래 여백
          const HomeWeekCalendar(),
          const SizedBox(height: _sectionGap),
          const HomeCheerBanner(),
          const SizedBox(height: _sectionGap),
          // 기존 HomeRoutineListSection 내용을 ListView 내부에 병합
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '루틴 리스트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '3개 남음',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _RoutineCard(
            icon: Icons.self_improvement_outlined,
            iconBackground: Color(0xFFE8F5E9),
            title: '아침 요가',
            subtitle: '오전 07:00',
            completed: false,
            iconFilled: false,
          ),
          const SizedBox(height: 16),
          const _RoutineCard(
            icon: Icons.menu_book_outlined,
            iconBackground: Color(0xFFE3F2FD),
            title: '독서 10페이지',
            subtitle: '오전 09:00',
            completed: false,
            iconFilled: true,
          ),
          const SizedBox(height: 16),
          const _RoutineCard(
            icon: Icons.water_drop,
            iconBackground: Colors.white,
            title: '물 2L 마시기',
            subtitle: '하루 종일',
            completed: true,
            iconFilled: true,
          ),
          const SizedBox(height: 16),
          // 루틴 추가 버튼 (Centered)
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          '루틴 추가하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 하단 바 높이만큼 여백 추가 (시스템 bottom inset 포함)
          SizedBox(height: 120 + bottomInset),
        ],
      ),
    );
  }
}

/// 시안 상단 주간 캘린더(월~토).
class HomeWeekCalendar extends StatelessWidget {
  const HomeWeekCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      ('월', '12', _DayStyle.plain),
      ('화', '13', _DayStyle.plain),
      ('수', '14', _DayStyle.selected),
      ('목', '15', _DayStyle.plain),
      ('금', '16', _DayStyle.plain),
      ('토', '17', _DayStyle.saturday),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _plushShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final d in days)
            _DayColumn(label: d.$1, day: d.$2, style: d.$3),
        ],
      ),
    );
  }
}

enum _DayStyle { plain, selected, saturday }

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.day,
    required this.style,
  });

  final String label;
  final String day;
  final _DayStyle style;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.secondary,
    );

    Widget dayChip;
    switch (style) {
      case _DayStyle.selected:
        dayChip = Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: _plushShadow,
          ),
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      case _DayStyle.saturday:
        dayChip = SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      case _DayStyle.plain:
        dayChip = SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        dayChip,
      ],
    );
  }
}

/// 시안 중앙 응원 배너(베이지 박스 + 쿼카).
class HomeCheerBanner extends StatelessWidget {
  const HomeCheerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 192,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                boxShadow: _plushShadow,
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        // [수정] 쿼카 캐릭터를 오른쪽 끝으로 붙이기 위해 텍스트 여백을 조정
                        padding: const EdgeInsets.only(right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '오늘의 응원',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '오늘도 힘내요!\n쿼카가 응원할게요',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // [수정] 쿼카 캐릭터 위치 및 크기 조정
            Positioned(
              right: 0, // 오른쪽 여백 제거 (오른쪽 끝으로 이동)
              bottom: 30,
              child: SizedBox(
                // 크기 약간 축소 (기존 160x176 -> 140x154)
                width: 140,
                height: 154,
                child: Image.asset(
                  'assets/images/quokka_cheerleader.webp',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.iconFilled,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool completed;
  final bool iconFilled;

  @override
  Widget build(BuildContext context) {
    final leadingRow = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface ?? Colors.black87,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: completed
            ? (AppColors.surfaceContainerLow ?? Colors.grey.shade100)
                .withOpacity(0.3)
            : AppColors.surfaceContainerLowest ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _plushShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: completed
                ? Opacity(opacity: 0.5, child: leadingRow)
                : leadingRow,
          ),
          const SizedBox(width: 12),
          if (completed)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: AppColors.primary.withOpacity(0.35),
              ),
            ),
        ],
      ),
    );
  }
}