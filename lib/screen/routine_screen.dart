import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('성취도 리포트', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.local_fire_department, color: AppColors.primary, size: 48),
                SizedBox(height: 12),
                Text('현재 3일 연속 달성 중!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                Text('조금만 더 힘내볼까요?', style: TextStyle(color: AppColors.textSub)),
              ],
            ),
          )
        ],
      ),
    );
  }
}