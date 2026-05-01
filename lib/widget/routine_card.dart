import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../provider/routine_provider.dart';
import '../widget/app_modal.dart';
import '../widget/custom_snackbar.dart';
import 'package:vibration/vibration.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    super.key,
    required this.routineId, 
    required this.icon, 
    required this.backgroundColor,
    required this.foregroundColor, 
    required this.title, 
    required this.subtitle, 
    required this.completed,
    required this.rawData,
    required this.isFuture,
  });

  final int routineId; 
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String title;
  final String subtitle;
  final bool completed;
  final Map<String, dynamic> rawData;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final Color currentBackgroundColor = completed ? AppColors.surfaceContainer : backgroundColor;
    final Color currentForegroundColor = completed ? AppColors.outline : foregroundColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      // 🚀 1. 카드 전체 영역 터치 시: 루틴 수정(통합 창) 바텀시트 호출
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // 여백을 터치해도 인식하도록 설정
        onTap: () {
          AppModals.showRoutineFormBottomSheet(context, routine: rawData);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: completed ? AppColors.surfaceContainerLow.withOpacity(0.5) : AppColors.surfaceContainerLowest, 
            borderRadius: BorderRadius.circular(16), 
            boxShadow: AppShadows.plushShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: completed ? 0.5 : 1.0,
                  child: Row(
                    children: [
                      // 🚀 2. 아이콘 영역 터치 시: 아이콘 픽커 바텀시트 호출
                      GestureDetector(
                        onTap: () async {
                          final IconData? pickedIcon = await AppModals.showIconPickerBottomSheet(context);
                          
                          // 선택한 아이콘이 있고, 화면이 열려있다면 즉시 서버에 업데이트 요청
                          if (pickedIcon != null && context.mounted) {
                            final provider = context.read<RoutineProvider>();
                            final int userId = rawData['user_id'] ?? rawData['userId'] ?? 1;
                            final String timeRaw = rawData['alarm_time'] ?? rawData['alarmTime'] ?? '09:00:00';
                            final String daysRaw = rawData['days_of_week'] ?? rawData['daysOfWeek'] ?? 'MON,TUE,WED,THU,FRI,SAT,SUN';
                            
                            await provider.updateRoutine(
                              routineId, userId, title, pickedIcon, daysRaw.split(','), timeRaw
                            );
                          }
                        },
                        child: Container(
                          width: 40, height: 40, 
                          decoration: BoxDecoration(
                            color: currentBackgroundColor, 
                            borderRadius: BorderRadius.circular(12)
                          ), 
                          child: Icon(icon, color: currentForegroundColor, size: 22)
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // 타이틀 & 서브타이틀 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title, 
                              overflow: TextOverflow.ellipsis, 
                              style: TextStyle(
                                fontSize: 15, 
                                fontWeight: FontWeight.w700, 
                                color: AppColors.onSurface, 
                                decoration: completed ? TextDecoration.lineThrough : null
                              )
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle, 
                              style: const TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.w500, 
                                color: AppColors.secondary
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),

              // 🚀 3. 완료 체크 토글 버튼 (기존 로직 유지)
              GestureDetector(
                onTap: () async {
                  if (isFuture) {
                    CustomSnackBar.show(context, message: '미래의 루틴은 미리 체크할 수 없어요!', isError: true);
                    return;
                  }
                  
                  bool? hasVibrator = await Vibration.hasVibrator();
                  if (hasVibrator == true && !completed) {
                    Vibration.vibrate(duration: 80, amplitude: 64);
                  }
                  
                  if(context.mounted) {
                    context.read<RoutineProvider>().toggleRoutineCheck(context, routineId);
                  }
                },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: completed ? AppColors.primary : Colors.transparent, 
                    shape: BoxShape.circle, 
                    border: completed ? null : Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
                  ),
                  child: Icon(Icons.check, color: completed ? Colors.white : AppColors.primary.withOpacity(0.35), size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}