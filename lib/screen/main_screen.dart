import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'statistics_screen.dart';

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
              child: const Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          _titles[_currentIndex], // 💡 현재 탭에 맞춰 제목 변경 (홈/통계/프로필)
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
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
              color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}