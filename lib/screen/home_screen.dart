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
    // 화면 시작할 때 오늘 날짜의 루틴을 한 번 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().changeDateAndFetch(DateTime.now());
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
                            final int iconId = routine['icon_id'] ?? routine['iconId'] ?? 20; 
                            final IconData matchedIcon = AppIcons.routineIcons[(iconId - 1).clamp(0, AppIcons.routineIcons.length - 1)];
                            
                            // 시간 문자열 가공 ("09:00:00" -> "09:00")
                            String timeRaw = routine['alarm_time'] ?? routine['alarmTime'] ?? '';
                            String displayTime = timeRaw.length >= 5 ? timeRaw.substring(0, 5) : timeRaw;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: RoutineCard(
                                routineId: routine['id'] ?? 0,
                                icon: matchedIcon, 
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

// --- 주간 달력 ---
class HomeWeekCalendar extends StatefulWidget {
  const HomeWeekCalendar({super.key});

  @override
  State<HomeWeekCalendar> createState() => _HomeWeekCalendarState();
}

class _HomeWeekCalendarState extends State<HomeWeekCalendar> {
  late final PageController _pageController;
  late final DateTime _baseMonday;

  @override
  void initState() {
    super.initState();
    // 💡 500페이지를 '이번 주'로 설정하여 양방향 무한 스크롤이 가능하게 함
    _pageController = PageController(initialPage: 500);
    
    // 💡 오늘 날짜 기준으로 '이번 주 월요일' 날짜를 미리 계산해둠
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.plushShadow),
      child: SizedBox(
        height: 75, // 기존 65 -> 75로 변경 (4px OVERFLOW 에러 해결)
        child: PageView.builder( // ListView -> PageView로 변경하여 툭툭 끊어지는 슬라이드 적용
          controller: _pageController,
          itemBuilder: (context, pageIndex) {
            // 페이지 인덱스에 따라 해당 주의 '월요일'을 계산
            final int weekOffset = pageIndex - 500;
            final DateTime weekStartDate = _baseMonday.add(Duration(days: weekOffset * 7));

            // 한 페이지 안에 Row를 써서 7일(월~일)을 고정 배치
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (dayIndex) {
                final date = weekStartDate.add(Duration(days: dayIndex));
                final bool isSelected = DateUtils.isSameDay(selectedDate, date);
                final bool isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                _DayStyle style = _DayStyle.plain;
                if (isSelected) style = _DayStyle.selected;
                else if (isWeekend) style = _DayStyle.weekend;

                // Expanded를 씌워서 가로 여백 오버플로우를 막고 7개가 딱 맞게 분배됨
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque, // 투명한 여백을 눌러도 클릭되게 함
                    onTap: () => routineProvider.changeDateAndFetch(date), 
                    child: _DayColumn(
                      label: DateFormat('E', 'ko_KR').format(date),
                      day: date.day.toString(),
                      style: style,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

enum _DayStyle { plain, selected, weekend }

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
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: AppShadows.plushShadow),
          child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        );
      case _DayStyle.weekend:
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