import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _horizontalPadding = 24;
  static const double _sectionGap = 32;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 🚨 AppBar 삭제됨: MainScreen이 이미 그려주고 있으므로 여기선 필요 없습니다!
      
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 24), // 상단바가 사라진 대신 상단 여백을 살짝 줍니다.
          const HomeWeekCalendar(),
          const SizedBox(height: _sectionGap),
          const HomeCheerBanner(),
          const SizedBox(height: _sectionGap),
          const Row(
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
          SizedBox(height: 120 + bottomInset),
        ],
      ),
    );
  }
}

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
        color: AppColors.surfaceContainerLowest, // 💡 불필요한 ?? 구문 제거
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.plushShadow, // 💡 전역 그림자 적용!
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
  const _DayColumn({required this.label, required this.day, required this.style});

  final String label;
  final String day;
  final _DayStyle style;

  @override
  Widget build(BuildContext context) {
    Widget dayChip;
    switch (style) {
      case _DayStyle.selected:
        dayChip = Container(
          width: 40, height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary, 
            shape: BoxShape.circle, 
            boxShadow: AppShadows.plushShadow // 💡 전역 그림자 적용!
          ),
          child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        );
      case _DayStyle.saturday:
        dayChip = SizedBox(width: 40, height: 40, child: Center(child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))));
      case _DayStyle.plain:
        dayChip = SizedBox(width: 40, height: 40, child: Center(child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface))));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.secondary)),
        const SizedBox(height: 8),
        dayChip,
      ],
    );
  }
}

class HomeCheerBanner extends StatelessWidget {
  const HomeCheerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 192,
        child: Stack(
          children: [
            Container(
              width: double.infinity, 
              decoration: BoxDecoration(
                color: AppColors.primaryContainer, 
                boxShadow: AppShadows.plushShadow // 💡 전역 그림자 적용!
              ),
            ),
            Positioned(top: -40, right: -40, child: Container(width: 128, height: 128, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.3)))),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('오늘의 응원', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                    SizedBox(height: 4),
                    Text('오늘도 힘내요!\n쿼카가 응원할게요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.onPrimaryContainer)),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: 140, height: 154,
                child: Image.asset('assets/images/quokka_cheerleader.webp', fit: BoxFit.contain, alignment: Alignment.bottomRight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.icon, required this.iconBackground, required this.title, required this.subtitle, required this.completed, required this.iconFilled});

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool completed;
  final bool iconFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: completed ? AppColors.surfaceContainerLow.withOpacity(0.3) : AppColors.surfaceContainerLowest, // 💡 불필요한 ?? 구문 제거
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.plushShadow, // 💡 전역 그림자 적용!
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: completed ? 0.5 : 1.0,
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 26)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, decoration: completed ? TextDecoration.lineThrough : null)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: completed ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: completed ? null : Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.check, color: completed ? Colors.white : AppColors.primary.withOpacity(0.35), size: 18),
          ),
        ],
      ),
    );
  }
}