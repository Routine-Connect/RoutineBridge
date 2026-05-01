import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // 🚀 주간 그래프용 패키지
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../../provider/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 화면 진입 시 통계 데이터(주간 그래프 데이터 등) 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadFullStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 24),
          // 1. 기존 성취도 배너 (유지)
          _MonthlySummaryCard(),
          
          SizedBox(height: 24),
          // 2. 🚀 최장 연속/성실 루틴을 빼고 추가된 주간 루틴 통계 그래프
          _WeeklyGraphCard(),
          
          SizedBox(height: 24),
          // 3. 기존 월간 루틴 달력 (유지 - 추후 퍼센트 연동)
          _RoutineCalendar(),
          
          SizedBox(height: 24),
          // 4. 기존 나의 기록 공유하기 (유지)
          _ShareStreakCard(),
          
          // 🚨 하단 네비게이션 바 플로팅 영역 확보용 여백 (필수)
          SizedBox(height: 180),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. 성취도 배너 (개발자님 기존 코드 유지)
// ============================================================================
class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context) {
    // 🚀 Provider에서 계산해둔 성취도를 가져옵니다.
    final statsProvider = context.watch<StatisticsProvider>();
    final int achievementRate = statsProvider.monthlyAchievementRate;
    final double widthFactor = (achievementRate / 100.0).clamp(0.0, 1.0); // 바(Bar) 게이지용 비율

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACHIEVEMENT',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: AppColors.primary, letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '이번 달 성취도 $achievementRate%', // 🚀 실제 퍼센트 연동
                      style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppColors.onPrimaryContainer, letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // 💡 팁: 이전 달 대비 성장은 로직이 복잡해질 수 있으니, 일단 귀여운 응원 문구로 대체했습니다.
                      achievementRate >= 80 ? '아주 훌륭한 페이스예요! 🔥' : '오늘도 조금씩 나아가고 있어요!',
                      style: TextStyle(
                        fontSize: 14, color: AppColors.secondary.withOpacity(0.9), fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 90, height: 90,
                child: Image.asset('assets/images/quokka_manager.webp', fit: BoxFit.contain),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary.withOpacity(0.7))),
              Text('100%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor, // 🚀 실제 퍼센트만큼 바 채우기
              child: Container(
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🚀 2. 주간 루틴 통계 그래프 (새로 삽입됨)
// ============================================================================
class _WeeklyGraphCard extends StatelessWidget {
  const _WeeklyGraphCard();

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();
    final weeklyData = statsProvider.weeklyStats;
    final isLoading = statsProvider.isLoading; // 로딩 상태 추가

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 주 달성률', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          const SizedBox(height: 32),
          
          // 그래프 영역
          SizedBox(
            height: 220,
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : weeklyData.isEmpty 
                  ? const Center(child: Text('데이터를 불러올 수 없습니다.', style: TextStyle(color: AppColors.secondary)))
                  : _buildChart(weeklyData),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, double> data) {
    List<FlSpot> spots = [];
    List<String> dates = data.keys.toList(); // 서버가 준 7일 치 날짜 배열 (과거 -> 오늘)
    
    final today = DateUtils.dateOnly(DateTime.now());

    // 1. 데이터 점(Spot) 연동
    for (int i = 0; i < dates.length; i++) {
      DateTime date = DateTime.parse(dates[i]);
      
      // 혹시 모를 미래 날짜 방어 로직
      if (date.isAfter(today)) continue; 
      
      // X축은 index(0~6), Y축은 서버에서 온 퍼센트 값(0.0 ~ 100.0)
      spots.add(FlSpot(i.toDouble(), data[dates[i]]!));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100, // Y축 0~100%
        minX: 0,
        maxX: 6,   // X축 데이터 개수(7개)
        
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.secondary.withOpacity(0.1),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // Y축 (0, 25, 50, 75, 100)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: const TextStyle(color: AppColors.secondary, fontSize: 11));
              },
            ),
          ),
          
          // 🚀 X축 (서버 데이터 기반 동적 요일 매핑)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= dates.length) return const SizedBox.shrink();
                
                // 1) 서버에서 준 날짜 문자열("2026-04-20")을 날짜 객체로 변환
                DateTime date = DateTime.parse(dates[index]);
                
                // 2) 날짜 객체에서 요일 추출 (1:월, 2:화 ... 7:일)
                const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                String dayStr = weekdays[date.weekday - 1];
                
                // 3) 이 날짜가 '오늘'인지 확인 (오늘이면 색상 강조!)
                bool isToday = DateUtils.isSameDay(date, today);

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    dayStr,
                    style: TextStyle(
                      // 🚀 오늘은 메인 컬러로 진하게, 나머지는 회색으로!
                      color: isToday ? AppColors.primary : AppColors.secondary, 
                      fontSize: 13, 
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        
        // 곡선 그래프 디자인 세팅
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. 월간 루틴 달력 (개발자님 기존 코드 유지 - 추후 퍼센트 연동 예정)
// ============================================================================
class _RoutineCalendar extends StatelessWidget {
  const _RoutineCalendar();

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();
    final monthlyStats = statsProvider.monthlyStats;
    final currentMonth = statsProvider.currentMonth;
    final isLoading = statsProvider.isLoading;

    final List<String> weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    
    // 🚀 실제 달력을 그리기 위한 빈칸(여백) 및 데이터 계산 로직
    List<int> calendarData = [];
    int year = currentMonth.year;
    int month = currentMonth.month;

    // 이번 달 1일이 무슨 요일인지 알아냅니다 (일요일=0, 월요일=1 ... 토요일=6)
    DateTime firstDay = DateTime(year, month, 1);
    int paddingDays = firstDay.weekday % 7; 

    // 1일이 시작하기 전까지 빈칸(0) 채우기
    for (int i = 0; i < paddingDays; i++) {
      calendarData.add(0);
    }

    // 1일부터 말일까지 데이터 채우기
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int d = 1; d <= daysInMonth; d++) {
      // 날짜를 API 키 형식(yyyy-MM-dd)으로 맞춤
      String dateKey = "$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}";
      double? pct = monthlyStats[dateKey];

      if (pct == null) {
        calendarData.add(3); // 데이터 없음
      } else if (pct >= 100.0) {
        calendarData.add(1); // 100% 달성 -> 동그라미
      } else if (pct > 0.0) {
        calendarData.add(2); // 조금이라도 함 -> 세모
      } else {
        calendarData.add(3); // 0% -> 표시 없음
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.primaryContainer, width: 4)),
            ),
            child: Text(
              '${currentMonth.month}월 Routine', // 🚀 4월 하드코딩 -> 동적 월 표시
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day, textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: day == 'SUN' ? AppColors.logoutCoral : AppColors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          if (isLoading) 
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 40),
               child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
             )
          else 
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: calendarData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 4, childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                if (calendarData[index] == 0) return const SizedBox(); // 1일 이전의 빈칸 처리
                
                // 실제 표시할 날짜 (인덱스에서 빈칸 개수를 빼고 +1)
                int dayNumber = index - paddingDays + 1;
                bool isSunday = index % 7 == 0;
                
                return _DayCell(
                  day: dayNumber.toString(),
                  status: calendarData[index],
                  isSunday: isSunday,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String day;
  final int status;
  final bool isSunday;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isSunday,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSunday ? AppColors.logoutCoral : AppColors.onSurface,
          ),
        ),
        if (status == 1)
          Image.asset(
            'assets/images/circle.webp',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          )
        else if (status == 2)
          Image.asset(
            'assets/images/triangle.webp',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
      ],
    );
  }
}

// ============================================================================
// 4. 나의 기록 공유하기 (실시간 currentStreak 및 0일 방어 로직 적용)
// ============================================================================
class _ShareStreakCard extends StatelessWidget {
  const _ShareStreakCard();

  @override
  Widget build(BuildContext context) {
    // 🚀 1. StatisticsProvider에서 실시간 현재 연속 기록(currentStreak) 가져오기
    final statsProvider = context.watch<StatisticsProvider>();
    final int currentStreak = statsProvider.currentStreak;

    // 🚀 2. 0일 때와 1 이상일 때 보여줄 문구를 다르게 설정합니다.
    final bool isZero = currentStreak == 0;
    final String subtitleText = isZero ? '오늘부터 시작해볼까요?' : '$currentStreak일째 성공 중!';
    final String titleText = isZero ? 'START TODAY' : '$currentStreak DAY STREAK';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Column(
        children: [
          // 서브 타이틀 (n일째 성공 중! or 오늘부터 시작해볼까요?)
          Text(
            subtitleText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          // 메인 타이틀 (n DAY STREAK or START TODAY)
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.onPrimaryContainer,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 24),
          // 공유하기 버튼
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: 추후 공유하기 기능 연동
                },
                borderRadius: BorderRadius.circular(999),
                child: const Center(
                  child: Text(
                    '나의 기록 공유하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}