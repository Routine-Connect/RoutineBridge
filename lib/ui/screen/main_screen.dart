import 'package:flutter/material.dart';
import 'package:routine_app/ui/widget/app_modal.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'statistics_screen.dart';
import '../../provider/statistics_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 💡 화면 갈아끼우기용 배열
  static const List<Widget> _pages = [
    HomeScreen(),
    StatisticsScreen(),
    MyPageScreen(),
  ];

  // 💡 상단바 제목 갈아끼우기용 배열
  final List<String> _titles = ['홈', '통계', '프로필'];

  void _onTap(int index) {
    if (_currentIndex == index) return;

    // 🚀 [수정] 무조건적인 호출 대신 더티 플래그(_isDirty)가 true일 때만 서버 통신하도록 제어
    if (index == 1) {
      final statsProvider = context.read<StatisticsProvider>();
      // 데이터 변경이 감지되었을 때만 API를 호출하여 최적화
      if (statsProvider.isDirty) {
        statsProvider.loadSummaryOnly(); // 숫자 최신화
        statsProvider.loadFullStats();   // 그래프/달력 최신화
      }
    }
    else if (index == 2) {
      final statsProvider = context.read<StatisticsProvider>();
      // 프로필 탭 진입 시에도 변경사항이 있을 때만 요약 수치 갱신
      if (statsProvider.isDirty) {
        statsProvider.loadAllTimeStreak(); 
      }
    }
    
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      // 상단바
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.dividerFaint,
            width: 1.0,
          ),
        ),
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
          ),
        ),
        centerTitle: true,
        title: Text(
          _titles[_currentIndex], // 💡 현재 탭에 맞춰 제목 변경 (홈/통계/프로필)
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 🚀 달력 아이콘 누르면 날짜 선택 모달 띄우기
              AppModals.showDatePickerModal(context);
            },
            icon: Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _StitchBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _StitchBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _StitchBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.94),
        border: const Border(
          top: BorderSide(
            color: AppColors.dividerFaint,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false, // 상단은 무시
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8), // 얇고 예쁜 하단바 두께 형성
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: '홈',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                label: '통계',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: '프로필',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 GestureDetector 대신 InkWell을 쓰면 터치할 때 예쁜 물결 효과(Ripple)가 생깁니다.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 💡 최소 크기로 압축
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}