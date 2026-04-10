import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // 상단 영역 (월 표시 + 추가 버튼)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2026년 4월',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                  onPressed: () {
                    // TODO: 루틴 추가 화면 이동
                  },
                )
              ],
            ),
          ),

          // 주간 달력 영역
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
                bool isSelected = index == 1; // 임시 선택 상태

                return Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textMain : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekDays[index],
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? AppColors.cardWhite : AppColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 6}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.cardWhite : AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 10),

          // 루틴 리스트 영역
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildRoutineCard('☀️ 기상 시간 기록', '오전 07:00', true),
                _buildRoutineCard('💧 공복에 물 한 잔', '오전 07:10', false),
                _buildRoutineCard('🏃 아침 가벼운 스트레칭', '오전 07:30', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 루틴 카드 UI
  Widget _buildRoutineCard(String title, String time, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.accent : Colors.transparent,
              border: Border.all(color: isCompleted ? AppColors.accent : AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.textSub : AppColors.textMain,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.icon),
        ],
      ),
    );
  }
}