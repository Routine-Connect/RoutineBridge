import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'routine_screen.dart';

const double _kNavItemExtent = 80;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
  HomeScreen(),
  SizedBox.shrink(), // 통계 화면 임시 차단 (범인 격리)
  SizedBox.shrink(), // 마이페이지 임시 차단 (범인 격리)
];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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

/// 최적화된 하단 탭: 무거운 BackdropFilter(블러)를 제거하고 솔리드 컬러로 대체하여 에뮬레이터 멈춤 방지
class _StitchBottomNavBar extends StatelessWidget {
  const _StitchBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.98), // 블러 대신 불투명도를 높여서 깔끔하게 처리
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ]
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                selected: currentIndex == 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: '홈',
                onTap: () => onTap(0),
              ),
              _NavItem(
                selected: currentIndex == 1,
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: '통계',
                onTap: () => onTap(1),
              ),
              _NavItem(
                selected: currentIndex == 2,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: '프로필',
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
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconData = selected ? selectedIcon : icon;
    final labelStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 0.8,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _kNavItemExtent,
          height: _kNavItemExtent,
          child: AnimatedScale(
            scale: selected ? 1.05 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryContainer : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 26,
                    color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.toUpperCase(),
                    style: labelStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}