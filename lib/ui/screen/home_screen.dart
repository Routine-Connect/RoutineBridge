import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/user_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../theme/app_icon.dart';
import '../widget/app_modal.dart';
import '../../provider/routine_provider.dart';
import '../widget/custom_snackbar.dart';
import '../widget/routine_card.dart';
import 'dart:ui';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _horizontalPadding = 18;
  static const double _sectionGap = 24;

  // 🚀 [추가] 자동 숨김 기능을 위한 변수들
  bool _isButtonVisible = true; // 버튼이 보이는지 여부
  Timer? _hideTimer; // 시간을 잴 타이머

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().initMonthlyData();
    });
    _startHideTimer(); // 🚀 화면이 켜지면 타이머 시작!
  }

  @override
  void dispose() {
    _hideTimer?.cancel(); // 🚀 화면 꺼질 때 타이머가 계속 도는 걸 막음 (메모리 누수 방지)
    super.dispose();
  }

  // 🚀 [추가] 사용자가 화면을 건드렸을 때 실행될 함수
  void _handleInteraction() {
    if (!_isButtonVisible) {
      setState(() => _isButtonVisible = true); // 숨어있었다면 다시 보여줌!
    }
    _startHideTimer(); // 타이머를 초기화하고 다시 2초를 잽니다.
  }

  // 🚀 [추가] 2초 동안 터치 안 하면 스르륵 숨기는 함수
  void _startHideTimer() {
    _hideTimer?.cancel(); // 기존 타이머 취소
    _hideTimer = Timer(const Duration(seconds: 2), () {
      // 2초가 지났는데도 화면이 살아있다면 버튼 숨기기
      if (mounted) setState(() => _isButtonVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 🚀 1. Listener로 화면 전체를 감싸서 유저의 모든 터치/스크롤을 감지합니다!
      body: Listener(
        onPointerDown: (_) => _handleInteraction(), // 손가락이 닿을 때
        onPointerMove: (_) => _handleInteraction(), // 손가락이 움직일 때 (스크롤)
        child: Stack(
          children: [
            // 스크롤 되는 메인 콘텐츠 영역
            ListView(
              padding: EdgeInsets.only(
                left: _horizontalPadding,
                right: _horizontalPadding,
                bottom: 100 + bottomInset, 
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 24),
                HomeWeekCalendar(),
                SizedBox(height: _sectionGap),
                RoutineListHeader(),
                SizedBox(height: 16),
                HomeRoutineList(),
              ],
            ),

            // 2. 하단 버튼 (애니메이션 적용!)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24 + bottomInset, 
              // 🚀 2. AnimatedOpacity로 0.3초 만에 스르륵 나타나고 사라지게 만듭니다.
              child: AnimatedOpacity(
                opacity: _isButtonVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                // 🚀 3. IgnorePointer를 쓰면 버튼이 투명해졌을 때 뒤에 있는 루틴을 터치할 수 있습니다!
                child: IgnorePointer(
                  ignoring: !_isButtonVisible, // 숨어있을 땐 터치 무시!
                  child: const HomeAddRoutineButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================
// HomeScreen을 깔끔하게 만들기 위해 분리해낸 위젯
// ==============================================

/// 1. 루틴 리스트 헤더 위젯
class RoutineListHeader extends StatelessWidget {
  const RoutineListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '루틴 리스트', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

/// 2. 루틴 리스트 메인 위젯 (상태 구독 및 렌더링 로직 포함)
class HomeRoutineList extends StatelessWidget {
  const HomeRoutineList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        final routines = routineProvider.routines;
        final isLoading = routineProvider.isLoading;

        // 미래 날짜 판별 로직
        final selectedDate = DateUtils.dateOnly(routineProvider.selectedDate);
        final today = DateUtils.dateOnly(DateTime.now());
        final bool isFutureDate = selectedDate.isAfter(today);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 얇은 로딩 바
            SizedBox(
              height: 3,
              child: isLoading 
                  ? LinearProgressIndicator(color: Theme.of(context).colorScheme.primary, backgroundColor: Colors.transparent)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 13), 

            // 등록된 루틴이 없을 때
            if (routines.isEmpty && !isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '등록된 루틴이 없습니다.\n아래 버튼을 눌러 추가해보세요!', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondary, height: 1.5)
                  )
                ),
              ),

          // 루틴 리스트 렌더링
          if (routines.isNotEmpty || isLoading)
            Opacity(
              opacity: isLoading ? 0.4 : 1.0, 
              child: IgnorePointer(
                ignoring: isLoading, 
                // 🚀 [수정] ReorderableListView.builder로 교체
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  proxyDecorator: (Widget child, int index, Animation<double> animation) {
                    return Material(
                      color: Colors.transparent, // 기본 배경 투명하게
                      elevation: 0,              // 플러터 기본 그림자 제거
                      child: child,              // 네 RoutineCard 자체 그림자만 남음
                    );
                  },
                  
                  itemCount: isLoading && routines.isEmpty ? 0 : routines.length,
                  // 🚀 드래그 시작: 원본 리스트를 Provider에 전달
                  onReorderStart: (index) => context.read<RoutineProvider>().setReordering(true, routines),
                  onReorder: (int oldIndex, int newIndex) {
                    final provider = context.read<RoutineProvider>();
                    List<dynamic> updated = List.from(routines);
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = updated.removeAt(oldIndex);
                    updated.insert(newIndex, item);
                    
                    // 🚀 데이터 갱신 시마다 변경 여부 자동 체크
                    provider.updateLocalRoutines(updated);
                  },
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    
                    final int iconId = routine['icon_id'] ?? routine['iconId'] ?? 1; 
                    final IconData matchedIcon = AppIcons.routineIcons[(iconId - 1).clamp(0, 19)];
                    final Color matchedBackgroundColor = Theme.of(context).colorScheme.primaryContainer;
                    final Color matchedForegroundColor = AppIcons.routineIconForegroundColors[(iconId - 1).clamp(0, 19)];

                    String timeRaw = routine['alarm_time'] ?? routine['alarmTime'] ?? '';
                    String displayTime = timeRaw.length >= 5 ? timeRaw.substring(0, 5) : timeRaw;

                    return Padding(
                      key: ValueKey(routine['id']), // 🚀 필수: 드래그를 위한 고유 키값
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RoutineCard(
                        routineId: routine['id'] ?? 0,
                        icon: matchedIcon, 
                        backgroundColor: matchedBackgroundColor,
                        foregroundColor: matchedForegroundColor,
                        title: routine['title'] ?? '이름 없음',
                        subtitle: displayTime, 
                        completed: routine['is_completed'] ?? routine['isCompleted'] ?? false, 
                        rawData: routine, 
                        isFuture: isFutureDate,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 3. 루틴 추가 버튼 위젯
class HomeAddRoutineButton extends StatelessWidget {
  const HomeAddRoutineButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 Provider 상태 구독
    final provider = context.watch<RoutineProvider>();
    
    // 🚀 순서 변경 모드이면서, 실제로 변경이 일어났을 때만 버튼 활성화
    final bool showSaveButton = provider.isReordering && provider.hasChanges;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              // 🚀 버튼 색상에 맞춰 그림자 색도 연동
              color: (showSaveButton ? Colors.green : Theme.of(context).colorScheme.primary).withOpacity(0.25), 
              blurRadius: 12, 
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Material(
          // 🚀 [UI] 저장 모드면 녹색, 아니면 프라이머리 색상
          color: showSaveButton ? Colors.green : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            // 🚀 [기능] showSaveButton 조건에 따라 API 호출 또는 모달 호출
            onTap: showSaveButton 
                ? () => provider.saveRoutineOrder(provider.routines)
                : () => AppModals.showRoutineFormBottomSheet(context),
            splashColor: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(showSaveButton ? Icons.save_alt : Icons.add, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    showSaveButton ? '순서 저장하기' : '루틴 추가하기', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)
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


// 4. 홈 캘린더 위젯 (주간 뷰 + 스탬프 표시 로직 포함)
enum DayCompletionStatus { none, partial, full }

class HomeWeekCalendar extends StatefulWidget {
  const HomeWeekCalendar({super.key});

  @override
  State<HomeWeekCalendar> createState() => _HomeWeekCalendarState();
}

class _HomeWeekCalendarState extends State<HomeWeekCalendar> {
  late final PageController _pageController;
  late final DateTime _baseMonday;
  int _currentPageIndex = 500;
  DateTime? _lastSelectedDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 500);
    
    DateTime today = DateTime.now();
    int daysSinceMonday = today.weekday - 1; 
    _baseMonday = DateTime(today.year, today.month, today.day).subtract(Duration(days: daysSinceMonday));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();
    final selectedDate = routineProvider.selectedDate;

    final int currentWeekOffset = _currentPageIndex - 500;
    final DateTime visibleWeekStart = _baseMonday.add(Duration(days: currentWeekOffset * 7));

    // 🚀 상단 타이틀 월 계산 로직 (기존 유지)
    DateTime displayMonthDate;
    final normalizedSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final normalizedStart = DateTime(visibleWeekStart.year, visibleWeekStart.month, visibleWeekStart.day);
    final normalizedEnd = visibleWeekStart.add(const Duration(days: 6));

    bool isSelectedInVisibleWeek = normalizedSelected.isAtSameMomentAs(normalizedStart) || 
                                   normalizedSelected.isAtSameMomentAs(normalizedEnd) || 
                                   (normalizedSelected.isAfter(normalizedStart) && normalizedSelected.isBefore(normalizedEnd));

    if (isSelectedInVisibleWeek) {
      displayMonthDate = selectedDate;
    } else {
      displayMonthDate = visibleWeekStart.add(const Duration(days: 3));
    }

    if (_lastSelectedDate != selectedDate) {
      _lastSelectedDate = selectedDate; // 최신 날짜로 업데이트

      final int targetWeekOffset = (DateTime(selectedDate.year, selectedDate.month, selectedDate.day).difference(_baseMonday).inDays / 7).floor();
      final int targetPageIndex = 500 + targetWeekOffset;

      if (_currentPageIndex != targetPageIndex && _pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.animateToPage(
            targetPageIndex,
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeInOut,
          );
        });
      }
    }

    return Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppShadows.getPlushShadow(context),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 1. 상단 붉은 헤더 영역 (전체 모서리 곡률과 일치)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical:6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer, // 부드러운 붉은색
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Text(
          DateFormat('yyyy년 M월').format(displayMonthDate),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      
      // 2. 캘린더 본체 영역
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 75,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPageIndex = index);
              final int weekOffset = index - 500;
              final DateTime visibleDate = _baseMonday.add(Duration(days: weekOffset * 7 + 3));
              context.read<RoutineProvider>().fetchMonthData(visibleDate);
            },
            itemBuilder: (context, pageIndex) {
              final int weekOffset = pageIndex - 500;
              final DateTime weekStartDate = _baseMonday.add(Duration(days: weekOffset * 7));

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (dayIndex) {
                  final date = weekStartDate.add(Duration(days: dayIndex));
                  final bool isSelected = DateUtils.isSameDay(selectedDate, date);
                  final bool isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                  DayCompletionStatus completionStatus = _getCompletionStatus(routineProvider, date);

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => routineProvider.changeDateAndFetch(date),
                      child: _DayColumn(
                        date: date,
                        label: DateFormat('E', 'ko_KR').format(date),
                        day: date.day.toString(),
                        isSelected: isSelected,
                        isWeekend: isWeekend,
                        isDisabled: false,
                        completionStatus: completionStatus,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    ],
  ),
);
  }

  // 🚀 캐시된 월간 데이터를 기반으로 완료 상태(세모/동그라미)를 계산하는 함수
  DayCompletionStatus _getCompletionStatus(RoutineProvider provider, DateTime date) {
    String monthKey = DateFormat('yyyy-MM').format(date);
    String dateKey = DateFormat('yyyy-MM-dd').format(date);

    // 1. 창고(Cache)에서 해당 날짜의 루틴 뭉치를 꺼냄 (서버 통신 안 함!)
    final routines = provider.monthlyCache[monthKey]?[dateKey] ?? [];
    
    if (routines.isEmpty) return DayCompletionStatus.none;

    // 2. 완료된 루틴 개수 세기 (is_completed 와 isCompleted 둘 다 호환되게 체크)
    int completedCount = routines.where((r) => 
        r['is_completed'] == true || r['isCompleted'] == true
    ).length;

    // 3. 상태 반환
    if (completedCount == 0) return DayCompletionStatus.none;
    if (completedCount == routines.length) return DayCompletionStatus.full;
    return DayCompletionStatus.partial;
  }
}

class _DayColumn extends StatelessWidget {
  static const double _homeStampSize = 46.0; 

  final bool isDisabled;
  final DateTime date;

  const _DayColumn({
    required this.date,
    required this.label, 
    required this.day, 
    required this.isSelected,
    required this.isWeekend,
    required this.completionStatus,
    required this.isDisabled,
  });
  
  final String label;
  final String day;
  final bool isSelected;
  final bool isWeekend;
  final DayCompletionStatus completionStatus;

  @override
  Widget build(BuildContext context) {

   bool isSunday = date.weekday == DateTime.sunday;
    
    Color labelColor = isSunday ? const Color(0xFFF87171) : AppColors.secondary;
    if (isDisabled) labelColor = labelColor.withOpacity(0.3);

    Color dayTextColor = isSunday ? const Color(0xFFF87171) : AppColors.onSurface;
    if (isDisabled) dayTextColor = dayTextColor.withOpacity(0.3);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🚀 3. 요일 텍스트 영역
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 8),
        
        // 🚀 4. 요일 밀림 방지를 위해 Stack을 고정 크기 Container로 감싸기
        SizedBox(
          width: _homeStampSize, // 46px 고정
          height: _homeStampSize, // 46px 고정
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 선택 배경 (은은한 원)
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15) 
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),

              // 스탬프 이미지
              if (completionStatus != DayCompletionStatus.none)
                Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    completionStatus == DayCompletionStatus.full
                        ? 'assets/images/circle.webp'
                        : 'assets/images/triangle.webp',
                    width: _homeStampSize,
                    height: _homeStampSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),

              // 날짜 숫자
              Text(
                day, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w700, 
                  color: dayTextColor,
                  shadows: completionStatus != DayCompletionStatus.none 
                      ? [const Shadow(color: Colors.white, blurRadius: 4)] 
                      : null,
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}