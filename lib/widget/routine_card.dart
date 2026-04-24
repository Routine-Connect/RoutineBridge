import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

    return Slidable(
      // 💡 리스트 내 항목 식별을 위한 키
      key: ValueKey(routineId),

      // 🚀 오른쪽에서 왼쪽으로 밀었을 때 나타날 액션 (보내주신 로직 적용)
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45, // 슬라이드 메뉴가 차지할 가로 비율
        children: [
          // 1. 수정하기 액션
          SlidableAction(
            onPressed: (context) {
              // 보내주신 코드의 수정 로직 그대로 적용
              AppModals.showRoutineFormBottomSheet(context, routine: rawData);
            },
            backgroundColor: AppColors.swipeEdit,
            foregroundColor: AppColors.onPrimary,
            icon: Icons.edit,
            label: '수정',
          ),
          // 2. 삭제하기 액션
          SlidableAction(
            onPressed: (context) async {
              // 보내주신 코드의 삭제 확인 다이얼로그 로직 적용
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('루틴 삭제'),
                  content: const Text('정말로 이 루틴을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('취소', style: TextStyle(color: AppColors.secondary))),
                    TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<RoutineProvider>().deleteRoutine(routineId);
              }
            },
            backgroundColor: AppColors.swipeDelete,
            foregroundColor: AppColors.onPrimary,
            icon: Icons.delete,
            label: '삭제',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),

      // 💡 실제 화면에 보이는 카드 UI
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
                    Container(
                      width: 40, height: 40, 
                      decoration: BoxDecoration(color: currentBackgroundColor, borderRadius: BorderRadius.circular(12)), 
                      child: Icon(icon, color: currentForegroundColor, size: 22)
                    ),
                    const SizedBox(width: 12),
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
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.secondary)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),

            // 완료 체크 토글 버튼 (기존 로직 유지)
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
                  context.read<RoutineProvider>().toggleRoutineCheck(routineId);
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
    );
  }
}