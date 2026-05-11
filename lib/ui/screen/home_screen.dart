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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _horizontalPadding = 18;
  static const double _sectionGap = 24;

  @override
  void initState() {
    super.initState();
    // 🚀 화면 시작할 때 이번 달 기준으로 3개월치(전달, 이번달, 다음달) 데이터를 한 번에 싹 캐싱합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().initMonthlyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 24),
          // 상단 달력
          const HomeWeekCalendar(),
          const SizedBox(height: _sectionGap),
          
          // 루틴 리스트 헤더
          const RoutineListHeader(),
          const SizedBox(height: 16),

          // 데이터 연동 루틴 리스트
          const HomeRoutineList(),
          const SizedBox(height: _sectionGap),

          // 루틴 추가 버튼
          const HomeAddRoutineButton(),
          
          SizedBox(height: 25 + bottomInset),
        ],
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isLoading && routines.isEmpty ? 0 : routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      
                      final int iconId = routine['icon_id'] ?? routine['iconId'] ?? 1; 
                      final IconData matchedIcon = AppIcons.routineIcons[(iconId - 1).clamp(0, 19)];
                      final Color matchedBackgroundColor = Theme.of(context).colorScheme.primaryContainer;
                      final Color matchedForegroundColor = AppIcons.routineIconForegroundColors[(iconId - 1).clamp(0, 19)];

                      String timeRaw = routine['alarm_time'] ?? routine['alarmTime'] ?? '';
                      String displayTime = timeRaw.length >= 5 ? timeRaw.substring(0, 5) : timeRaw;

                      return Padding(
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
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 8))
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: () => AppModals.showRoutineFormBottomSheet(context), 
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('루틴 추가하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
    final userProvider = context.watch<UserProvider>();
    final joinDate = userProvider.currentUser?.createdAt;
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: AppShadows.getPlushShadow(context)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              DateFormat('yyyy년 M월').format(displayMonthDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
          ),
          
          SizedBox(
            height: 90, 
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPageIndex = index);
                final int weekOffset = index - 500;
                final DateTime visibleDate = _baseMonday.add(Duration(days: weekOffset * 7 + 3)); 

                // 🚀 [최적화] 가입 월 이전이라면 월간 데이터 fetch도 막습니다.
                if (joinDate != null) {
                  final targetMonth = DateTime(visibleDate.year, visibleDate.month, 1);
                  final joinMonth = DateTime(joinDate.year, joinDate.month, 1);
                  if (targetMonth.isBefore(joinMonth)) return;
                }
                
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

                    // 🚀 가입일 기준 날짜 정규화
                    final normalizedDate = DateTime(date.year, date.month, date.day);
                    final normalizedJoinDate = joinDate != null 
                        ? DateTime(joinDate.year, joinDate.month, joinDate.day) 
                        : null;

                    // 🚀 가입일 이전 날짜인지 판단
                    bool isBeforeJoin = normalizedJoinDate != null && normalizedDate.isBefore(normalizedJoinDate);

                    // 가입일 이전이면 스탬프 안 보여줌
                    DayCompletionStatus completionStatus = isBeforeJoin 
                        ? DayCompletionStatus.none 
                        : _getCompletionStatus(routineProvider, date);

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // 🚀 [핵심 수정] 가입일 이전 날짜를 눌렀을 때
                          if (isBeforeJoin) {
                            // 1. 선택된 날짜는 바꿉니다 (유저가 눌렀다는 반응은 줘야 하니까요)
                            // 2. 하지만 서버 통신은 막고, Provider의 리스트를 비워달라고 요청해야 합니다.
                            routineProvider.setSelectedDateOnly(date); 
                            CustomSnackBar.show(context, message: '가입 이전 기록은 볼 수 없어요!', isError: true);
                            return;
                          }
                          
                          // 가입일 이후일 때만 정상 통신
                          routineProvider.changeDateAndFetch(date);
                        },
                        child: _DayColumn(
                          label: DateFormat('E', 'ko_KR').format(date),
                          day: date.day.toString(),
                          isSelected: isSelected,
                          isWeekend: isWeekend,
                          // 🚀 가입 전 날짜는 숫자 색을 흐리게 처리해서 "비활성" 느낌을 줍니다 (UX 센스)
                          isDisabled: isBeforeJoin, 
                          completionStatus: completionStatus, 
                        ),
                      ),
                    );
                  }),
                );
              },
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

  const _DayColumn({
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
    Color labelColor = isWeekend ? const Color(0xFFF87171) : AppColors.secondary;
    if (isDisabled) labelColor = labelColor.withOpacity(0.3);

    Color dayTextColor = isWeekend ? const Color(0xFFF87171) : AppColors.onSurface;
    if (isDisabled) dayTextColor = dayTextColor.withOpacity(0.3);
    Color selectionBgColor = isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent;

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
                  color: selectionBgColor, 
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