import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/ui/widget/app_modal.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'statistics_screen.dart';
import '../../provider/statistics_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // 🚀 1. 스와이프를 담당할 핵심 컨트롤러 선언!
  late PageController _pageController;

  bool _isFirstStatsLoad = true;
  bool _isFirstMyPageLoad = true;

  // 💡 화면 갈아끼우기용 배열
  static const List<Widget> _pages = [
    HomeScreen(),
    StatisticsScreen(),
    MyPageScreen(),
  ];

  // 💡 상단바 제목 갈아끼우기용 배열
  final List<String> _titles = ['홈', '통계', '프로필'];

  @override
  void initState() {
    super.initState();
    // 🚀 2. 페이지 컨트롤러 초기화 (첫 시작은 0번 홈 화면)
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // 🚀 3. 메모리 누수 방지
    _pageController.dispose();
    super.dispose();
  }

  // 🚀 4. 하단 바 아이콘을 "터치"했을 때 실행될 함수
  void _onTap(int index) {
    if (_currentIndex == index) return;
    
    // PageView를 쓰면 탭 했을 때 알아서 _onPageChanged가 불리기 때문에
    // 여기서는 애니메이션 이동 명령만 내리면 됨!
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 🚀 5. 화면이 완전히 "스와이프" 되거나 탭 이동이 끝났을 때 실행될 함수
  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // 💡 네가 짜둔 '더티 플래그(isDirty) 최적화 로직'을 여기로 옮김!
    // 이렇게 하면 손가락으로 밀어서 넘어가든, 아이콘을 터치해서 넘어가든 완벽하게 작동함.
    if (index == 1) {
      final statsProvider = context.read<StatisticsProvider>();
      if (statsProvider.isDirty || _isFirstStatsLoad) {
        statsProvider.loadSummaryOnly(); 
        statsProvider.loadFullStats();   
        _isFirstStatsLoad = false;
      }
    } else if (index == 2) {
      final statsProvider = context.read<StatisticsProvider>();
      if (statsProvider.isDirty || _isFirstMyPageLoad) {
        statsProvider.loadAllTimeStreak(); 
        _isFirstMyPageLoad = false;
      }
    }
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
          bottom: BorderSide(color: AppColors.dividerFaint, width: 1.0),
        ),
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(),
        ),
        centerTitle: true,
        title: Text(
          _titles[_currentIndex], 
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              AppModals.showDatePickerModal(context);
            },
            icon: Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // 🚀 6. 기존 IndexedStack을 버리고 PageView로 교체!
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // 끝에 도달하면 '띠용'하는 애플 감성 스크롤
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
          top: BorderSide(color: AppColors.dividerFaint, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false, 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
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
                icon: Icons.person,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
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