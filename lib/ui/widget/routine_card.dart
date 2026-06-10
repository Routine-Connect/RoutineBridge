import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/util/api_error_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../../provider/routine_provider.dart';
import 'app_modal.dart';
import 'custom_snackbar.dart';
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

    // 🚀 [신규 추가] 알림 토글에 필요한 데이터를 rawData에서 추출
    final provider = context.read<RoutineProvider>();
    final int userId = rawData['user_id'] ?? rawData['userId'] ?? 1;
    final String timeRaw = rawData['alarm_time'] ?? rawData['alarmTime'] ?? '';
    final String daysRaw = rawData['days_of_week'] ?? rawData['daysOfWeek'] ?? 'MON,TUE,WED,THU,FRI,SAT,SUN';
    final bool isAlarmEnabled = rawData['is_alarm_enabled'] == true || rawData['isAlarmEnabled'] == true;

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
            boxShadow: AppShadows.getPlushShadow(context),
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
                            await provider.updateRoutine(
                              routineId, userId, title, pickedIcon, daysRaw.split(','), timeRaw.isNotEmpty ? timeRaw : '09:00:00', isAlarmEnabled
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
                      
                      // 🚀 타이틀 & 미니멀 알림 버튼 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            
                            // 🔥 [신규 기획 UI] 알림 토글 버튼 (배경 테두리 제거, 깔끔한 미니멀형)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque, // 아이콘 주변 여백도 터치 인식
                              onTap: () async {
                                if (completed) return; // 완료 상태면 알림 토글 막기

                                if (!isAlarmEnabled) {
                                  // 💡 켜려고 할 때: 시간이 비어있으면 최초 1회 타임피커 호출
                                  if (timeRaw.isEmpty) {
                                    final TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                                    );
                                    if (pickedTime == null) return; // 취소 시 무시

                                    // DB 포맷에 맞게 변환 (HH:mm:ss)
                                    final String formattedTime = 
                                        "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                                    
                                    await ApiErrorHandler.execute(context, () async {
                                      await provider.toggleRoutineAlarm(routineId, true, formattedTime, rawData);
                                    });
                                  } else {
                                    // 💡 과거에 쓰던 시간이 남아있으면 바로 ON!
                                    await ApiErrorHandler.execute(context, () async {
                                      await provider.toggleRoutineAlarm(routineId, true, timeRaw, rawData);
                                    });
                                  }
                                } else {
                                  // 💡 끄려고 할 때: 시간은 유지하되 상태만 OFF
                                  await ApiErrorHandler.execute(context, () async {
                                    await provider.toggleRoutineAlarm(routineId, false, timeRaw.isNotEmpty ? timeRaw : '09:00:00', rawData);
                                  });
                                }
                              },
                              // 🚀 배경을 날리고 터치 영역(Padding)만 남김
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2), // 💡 미세한 수직 터치 영역만 확보
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isAlarmEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                                      size: 14, // 👈 이 14px 아이콘이 기둥 역할을 해서 세로 높이를 지탱함!
                                      color: isAlarmEnabled ? Theme.of(context).colorScheme.primary : AppColors.outline.withOpacity(0.4),
                                    ),
                                    if (isAlarmEnabled && timeRaw.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        timeRaw.length >= 5 ? timeRaw.substring(0, 5) : timeRaw, 
                                        style: TextStyle(
                                          fontSize: 12, 
                                          height: 1.0, // 👈 배수 개념! 글자 뽕을 깎아서 12px로 고정!
                                          fontWeight: FontWeight.w600, 
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),

              // 🚀 3. 완료 체크 토글 버튼 (네가 준 기존 코드 100% 그대로 유지!)
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
                    color: completed ? Theme.of(context).colorScheme.primary : Colors.transparent, 
                    shape: BoxShape.circle, 
                    border: completed ? null : Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 2)
                  ),
                  child: Icon(Icons.check, color: completed ? Colors.white : Theme.of(context).colorScheme.primary.withOpacity(0.35), size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}