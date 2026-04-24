import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../theme/app_icon.dart';
import '../widget/app_modal.dart';
import '../provider/routine_provider.dart';
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
          const HomeWeekCalendar(),
          const SizedBox(height: _sectionGap),
          const HomeCheerBanner(),
          const SizedBox(height: _sectionGap),
          
          // 루틴 리스트 헤더
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('루틴 리스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),

          // 🚀 데이터 연동된 루틴 리스트 (깜빡임 없는 부드러운 로딩 UX 적용)
          Consumer<RoutineProvider>(
            builder: (context, routineProvider, child) {
              final routines = routineProvider.routines;
              final isLoading = routineProvider.isLoading;

              // 💡 미래 날짜 판별 로직 추가 (시간은 무시하고 '날짜'만 비교합니다)
              final selectedDate = DateUtils.dateOnly(routineProvider.selectedDate);
              final today = DateUtils.dateOnly(DateTime.now());
              final bool isFutureDate = selectedDate.isAfter(today);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 상단 얇은 로딩 바 (공간이 들썩거리지 않게 고정 높이 지정)
                  SizedBox(
                    height: 3,
                    child: isLoading 
                        ? const LinearProgressIndicator(color: AppColors.primary, backgroundColor: Colors.transparent)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 13), // 기존 여백 16에서 로딩바 높이(3)를 뺀 값

                  // 2. 등록된 루틴이 없을 때 (로딩 중이 아닐 때만 표시)
                  if (routines.isEmpty && !isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('등록된 루틴이 없습니다.\n아래 버튼을 눌러 추가해보세요!', 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.secondary, height: 1.5)
                        )
                      ),
                    ),

                  // 3. 루틴 리스트 렌더링 (핵심!)
                  if (routines.isNotEmpty || isLoading)
                    Opacity(
                      opacity: isLoading ? 0.4 : 1.0, // 💡 로딩 중일 때는 40% 투명도로 흐려짐
                      child: IgnorePointer(
                        ignoring: isLoading, // 💡 로딩 중일 때는 중복 클릭 방지
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isLoading && routines.isEmpty ? 0 : routines.length, // 데이터가 아예 없는데 로딩 중이면 안그림
                          itemBuilder: (context, index) {
                            final routine = routines[index];
                            
                            // 서버에서 받은 icon_id 추출 
                            final int iconId = routine['icon_id'] ?? routine['iconId'] ?? 1; 
                            // 🚀 리스트에서 아이콘, 배경색, 전경색을 인덱스로 찾기
                            final IconData matchedIcon = AppIcons.routineIcons[(iconId - 1).clamp(0, 19)];
                            final Color matchedBackgroundColor = AppIcons.routineIconBackgroundColors[(iconId - 1).clamp(0, 19)];
                            final Color matchedForegroundColor = AppIcons.routineIconForegroundColors[(iconId - 1).clamp(0, 19)];

                            // 시간 문자열 가공 ("09:00:00" -> "09:00")
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
          ),
          const SizedBox(height: _sectionGap),

          // 🚀 루틴 추가 버튼 (모달 연결)
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 8))],
              ),
              child: Material(
                color: AppColors.primary,
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
          ),
          SizedBox(height: 25 + bottomInset),
        ],
      ),
    );
  }
}

// --- 완료 상태를 구분하기 위한 Enum ---
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
    final selectedDate = routineProvider.selectedDate;

    final int currentWeekOffset = _currentPageIndex - 500;
    final DateTime visibleWeekStart = _baseMonday.add(Duration(days: currentWeekOffset * 7));
    final DateTime visibleMonthDate = visibleWeekStart.add(const Duration(days: 3));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: AppShadows.plushShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              DateFormat('yyyy년 M월').format(visibleMonthDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
          ),
          
          SizedBox(
            height: 90, // 🚀 1. 높이를 90으로 넉넉히 키워 이미지 깨짐 방지
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPageIndex = index);
                // 🚀 유저가 달력을 넘기면, 해당 주(목요일 기준)가 포함된 달의 데이터를 미리 몰래 가져옵니다.
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

                    // 🚀 2. 스탬프 상태 계산 (SelectedDate 체크 해제)
                    // 현재 Provider는 선택된 날짜의 루틴만 들고 있으므로, 
                    // 선택된 날짜에 대해서만 스탬프를 실시간으로 보여줍니다.
                    DayCompletionStatus completionStatus = _getCompletionStatus(routineProvider, date);

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => routineProvider.changeDateAndFetch(date), 
                        child: _DayColumn(
                          label: DateFormat('E', 'ko_KR').format(date),
                          day: date.day.toString(),
                          isSelected: isSelected,
                          isWeekend: isWeekend,
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

  const _DayColumn({
    required this.label, 
    required this.day, 
    required this.isSelected,
    required this.isWeekend,
    required this.completionStatus,
  });
  
  final String label;
  final String day;
  final bool isSelected;
  final bool isWeekend;
  final DayCompletionStatus completionStatus;

  @override
  Widget build(BuildContext context) {
    Color labelColor = isWeekend ? const Color(0xFFF87171) : AppColors.secondary;
    Color dayTextColor = isWeekend ? const Color(0xFFF87171) : AppColors.onSurface;
    Color selectionBgColor = isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent;

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

// --- 응원 배너 ---
class HomeCheerBanner extends StatelessWidget {
  const HomeCheerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192, width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.plushShadow),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('오늘의 응원', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
                SizedBox(height: 4),
                Text('오늘도 힘내요!\n쿼카가 응원할게요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
              ],
            ),
          ),
          Positioned(right: -3, bottom: 25, child: Image.asset('assets/images/quokka_cheerleader.webp', width: 150, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}