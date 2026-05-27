import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../theme/app_icon.dart';
import 'custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../provider/user_provider.dart';
import '../../provider/routine_provider.dart';
import '../../provider/theme_provider.dart';

class AppModals {
  
  // 🚀 1. 닉네임 수정 모달 (Center Dialog)
  static Future<String?> showNicknameEditDialog(
    BuildContext context, {
    required String currentNickname,
  }) async {
    final TextEditingController controller = TextEditingController(text: currentNickname);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('닉네임 변경', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '새로운 닉네임을 입력하세요',
                    hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                    filled: true, fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🚀 2. 루틴 아이콘 선택 바텀시트
  static Future<IconData?> showIconPickerBottomSheet(BuildContext context) async {
    return showModalBottomSheet<IconData>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('루틴 아이콘 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16),
                
                itemCount: AppIcons.routineIcons.length,
                itemBuilder: (context, index) {
                  // 💡 각 아이콘에 맞는 배경색과 전경색을 가져옵니다.
                  final icon = AppIcons.routineIcons[index];
                  final bgColor = Theme.of(context).colorScheme.primaryContainer;
                  final fgColor = AppIcons.routineIconForegroundColors[index];

                  return InkWell(
                    onTap: () => Navigator.pop(context, icon),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      // 🚀 연한 배경색 적용
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      // 🚀 선명한 전경색 적용
                      child: Icon(icon, color: fgColor, size: 28),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // 🚀 통합 루틴 폼 바텀시트
  static Future<void> showRoutineFormBottomSheet(
    BuildContext context, {
    Map<String, dynamic>? routine, 
  }) async {
    final bool isEditMode = routine != null; 
    final TextEditingController nameController = TextEditingController(text: isEditMode ? routine['title'] : '');
    
    // 시간 복구: "09:00:00" -> "09", "00" 분리
    final String timeRaw = isEditMode ? (routine['alarm_time'] ?? routine['alarmTime'] ?? '09:00:00') : '09:00:00';
    final List<String> timeParts = timeRaw.split(':');
    final TextEditingController hourController = TextEditingController(text: timeParts[0]);
    final TextEditingController minuteController = TextEditingController(text: timeParts.length > 1 ? timeParts[1].substring(0,2) : '00');
    
    final int iconId = isEditMode ? (routine['icon_id'] ?? routine['iconId'] ?? 1) : 1; 
    IconData selectedIcon = AppIcons.routineIcons[(iconId - 1).clamp(0, 19)]; 

    final String daysRaw = isEditMode ? (routine['days_of_week'] ?? routine['daysOfWeek'] ?? 'MON,TUE,WED,THU,FRI,SAT,SUN') : 'MON,TUE,WED,THU,FRI,SAT,SUN';
    List<String> selectedDays = daysRaw.split(',');

    // 🚀 [추가] 알림 설정 상태값 (기본값 false, 수정 시 DB 값 복구)
    bool isAlarmEnabled = isEditMode ? (routine['isAlarmEnabled'] ?? routine['is_alarm_enabled'] ?? false) : false;

    final List<Map<String, String>> weekDays = [
      {'key': 'MON', 'label': '월'}, {'key': 'TUE', 'label': '화'}, {'key': 'WED', 'label': '수'},
      {'key': 'THU', 'label': '목'}, {'key': 'FRI', 'label': '금'}, {'key': 'SAT', 'label': '토'}, {'key': 'SUN', 'label': '일'},
    ];

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, 
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        bool isSubmitting = false; 

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            
            // 💡 🚀 현재 선택된 아이콘이 리스트의 몇 번째인지 찾아서 색상을 매칭합니다!
            int currentIconIndex = AppIcons.routineIcons.indexOf(selectedIcon);
            if (currentIconIndex == -1) currentIconIndex = 0; // 안전장치
            final Color currentBgColor = Theme.of(context).colorScheme.primaryContainer;
            final Color currentFgColor = AppIcons.routineIconForegroundColors[currentIconIndex];

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom, left: 24, right: 24, top: 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 제목 및 삭제 버튼 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEditMode ? '루틴 수정하기' : '새로운 루틴 추가', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        
                        if (isEditMode)
                          IconButton(
                            onPressed: () async {
                              await context.read<RoutineProvider>().deleteRoutine(routine!['id']);
                              if (context.mounted) {
                                Navigator.pop(context); // 창 닫기
                                CustomSnackBar.show(context, message: '루틴이 삭제되었습니다.');
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- 아이콘 및 이름 입력 ---
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final IconData? pickedIcon = await showIconPickerBottomSheet(context);
                            if (pickedIcon != null) setState(() => selectedIcon = pickedIcon); 
                          },
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: currentBgColor, 
                              borderRadius: BorderRadius.circular(16), 
                              border: Border.all(color: currentFgColor.withOpacity(0.3))
                            ),
                            child: Icon(selectedIcon, color: currentFgColor, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: '루틴 이름을 입력하세요',
                              hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                              filled: true, fillColor: AppColors.surfaceContainer,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // --- 반복 요일 ---
                    const Text('반복 요일', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDays.map((day) {
                        final isSelected = selectedDays.contains(day['key']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                if (selectedDays.length > 1) {
                                  selectedDays.remove(day['key']);
                                } else {
                                  CustomSnackBar.show(context, message: '최소 하루는 선택해야 합니다.', isError: true);
                                }
                              } else {
                                selectedDays.add(day['key']!);
                                selectedDays.sort((a, b) => weekDays.indexWhere((d) => d['key'] == a).compareTo(weekDays.indexWhere((d) => d['key'] == b)));
                              }
                            });
                          },
                          child: Container(
                            width: 38, height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.surfaceContainerLowest,
                              border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                              shape: BoxShape.circle,
                            ),
                            child: Text(day['label']!, style: TextStyle(color: isSelected ? Colors.white : AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // --- 🚀 알림 설정 및 알림 시간 (수정된 부분) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('알림 시간', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                        
                        // 🚀 스위치 대신 [종 모양 아이콘 토글] 적용
                        GestureDetector(
                          onTap: () {
                            setState(() => isAlarmEnabled = !isAlarmEnabled);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // 켜졌을 때 살짝 노란 배경 하이라이트 (원치 않으면 Colors.transparent로 변경)
                              color: isAlarmEnabled ? Colors.amber.withOpacity(0.15) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isAlarmEnabled ? Icons.notifications_active : Icons.notifications_none,
                              color: isAlarmEnabled ? Colors.amber : AppColors.onSurfaceVariant,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // 알림 시간이 꺼져있을 땐 입력창을 흐리게 보이게 처리 (UX 디테일)
                    Opacity(
                      opacity: isAlarmEnabled ? 1.0 : 0.4,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: hourController,
                              enabled: isAlarmEnabled, // 알림 꺼지면 수정 불가
                              keyboardType: TextInputType.number, maxLength: 2, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(counterText: "", filled: true, fillColor: AppColors.surfaceContainer, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: minuteController,
                              enabled: isAlarmEnabled, // 알림 꺼지면 수정 불가
                              keyboardType: TextInputType.number, maxLength: 2, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(counterText: "", filled: true, fillColor: AppColors.surfaceContainer, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    
                    // --- 저장 버튼 ---
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isSubmitting ? null : () async {
                          if (nameController.text.trim().isEmpty) {
                            CustomSnackBar.show(context, message: '루틴 이름을 입력해주세요.', isError: true);
                            return;
                          }

                          int? h = int.tryParse(hourController.text);
                          int? m = int.tryParse(minuteController.text);
                          if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
                            CustomSnackBar.show(context, message: '올바른 시간을 입력해주세요 (00~23, 00~59).', isError: true);
                            return;
                          }

                          final user = context.read<UserProvider>().currentUser;
                          final int? userId = user?.id; 
                          if (userId == null) return;

                          setState(() => isSubmitting = true); 

                          try {
                            String formattedTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

                            // 🚀 [핵심] 이제 Provider 메서드에 isAlarmEnabled 값을 같이 넘겨줍니다!
                            if (routine != null) {
                              await context.read<RoutineProvider>().updateRoutine(
                                routine['id'], userId, nameController.text.trim(), selectedIcon, selectedDays, formattedTime, isAlarmEnabled
                              );
                            } else {
                              await context.read<RoutineProvider>().addRoutine(
                                userId, nameController.text.trim(), selectedIcon, selectedDays, formattedTime, isAlarmEnabled
                              );
                            }
                            
                            if (context.mounted) {
                              Navigator.pop(context); 
                              CustomSnackBar.show(context, message: (routine != null) ? '루틴이 수정되었습니다!' : '새 루틴이 추가되었습니다!');
                            }
                          } catch (e) {
                            if (context.mounted) CustomSnackBar.show(context, message: '실패: $e', isError: true);
                          } finally {
                            if (context.mounted) setState(() => isSubmitting = false); 
                          }
                        },
                        
                        child: isSubmitting 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEditMode ? '수정 저장하기' : '루틴 추가하기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );  
      },
    );
  }

  // 🚀 4. 비밀번호 변경 모달 
  static Future<String?> showPasswordEditDialog(BuildContext context) async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('비밀번호 변경', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: '새로운 비밀번호', filled: true, fillColor: AppColors.surfaceContainer, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: '비밀번호 확인', filled: true, fillColor: AppColors.surfaceContainer, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: AppColors.onSurfaceVariant))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: AppColors.onPrimary),
                      onPressed: () {
                        if (newPasswordController.text != confirmPasswordController.text) {
                          CustomSnackBar.show(context, message: '비밀번호가 일치하지 않습니다.', isError: true);
                          return;
                        }
                        Navigator.pop(context, newPasswordController.text);
                      },
                      child: const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🚀 5. 알림 설정 메뉴
  static Future<void> showNotificationSettingsBottomSheet(BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
      if (!status.isGranted && !status.isPermanentlyDenied) return;
    }
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림 권한 필요'),
          content: const Text('스마트폰 설정에서 알림 권한을 허용해 주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            TextButton(onPressed: () { openAppSettings(); Navigator.pop(context); }, child: const Text('설정으로 이동')),
          ],
        ),
      );
      return; 
    }

    if (!context.mounted) return;
    Provider.of<UserProvider>(context, listen: false).loadNotificationSettings();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final settings = userProvider.notificationSettings;
            if (settings == null) return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('알림 세부 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero, title: const Text('앱 알림 전체 켜기'), subtitle: const Text('앱에서 보내는 모든 알림을 제어합니다.'),
                    value: settings.isPushEnabled,
                    onChanged: (value) {
                      userProvider.updateNotification(settings.copyWith(isPushEnabled: value, isRoutineNotiEnabled: value ? settings.isRoutineNotiEnabled : false, isMarketingEnabled: value ? settings.isMarketingEnabled : false));
                    },
                  ),
                  const Divider(),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero, title: const Text('루틴 리마인더'),
                    value: settings.isRoutineNotiEnabled,
                    onChanged: settings.isPushEnabled ? (value) => userProvider.updateNotification(settings.copyWith(isRoutineNotiEnabled: value)) : null,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero, title: const Text('이벤트 및 혜택 알림'),
                    value: settings.isMarketingEnabled,
                    onChanged: settings.isPushEnabled ? (value) => userProvider.updateNotification(settings.copyWith(isMarketingEnabled: value)) : null,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showThemeSelectBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나만의 색상 선택하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Doday를 당신의 취향으로 물들여보세요.',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                
                // 🚀 테마 리스트 레이아웃
                Wrap(
                  spacing: 20,
                  runSpacing: 24,
                  children: DodayThemeType.values.map((type) {
                    final themeColors = AppColors.themes[type]!;
                    final isSelected = themeProvider.currentThemeType == type;

                    return GestureDetector(
                      onTap: () => themeProvider.setTheme(type),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: themeColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? themeColors.primary : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected 
                                    ? [BoxShadow(color: themeColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                                    : null,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: Colors.white, size: 28),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            themeColors.label,
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      );
    },
  );
  }
  // 🚀 상단바 달력 바텀 시트 (워프 기능)
  static Future<void> showDatePickerModal(BuildContext context) async {
    final routineProvider = context.read<RoutineProvider>();
    final initialDate = routineProvider.selectedDate;

    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        // 🚀 커스텀 달력 위젯 호출
        return _CustomCalendarModal(initialDate: initialDate);
      },
    );

    // 4. 유저가 날짜를 골랐다면 Provider를 업데이트해서 워프!
    if (pickedDate != null && context.mounted) {
      context.read<RoutineProvider>().changeDateAndFetch(pickedDate);
    }
  }
}

// ============================================================================
// 커스텀 달력
// ============================================================================
class _CustomCalendarModal extends StatefulWidget {
  final DateTime initialDate;
  const _CustomCalendarModal({required this.initialDate});

  @override
  State<_CustomCalendarModal> createState() => _CustomCalendarModalState();
}

class _CustomCalendarModalState extends State<_CustomCalendarModal> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    // 달력 처음 열었을 때 보여줄 달 (1일로 초기화)
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  // 🚀 [핵심] 위아래로 굴리는(Wheel) 년도 선택기 띄우기
  void _showYearPicker() {
    int tempYear = _displayedMonth.year;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // 확인 누르면 달력의 년도 업데이트
                    setState(() {
                      _displayedMonth = DateTime(tempYear, _displayedMonth.month, 1);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  // 2000년을 인덱스 0으로 잡음
                  scrollController: FixedExtentScrollController(initialItem: tempYear - 2000), 
                  itemExtent: 45,
                  onSelectedItemChanged: (index) {
                    tempYear = 2000 + index; // 선택한 년도 저장
                  },
                  // 2000년부터 2100년까지 리스트 생성
                  children: List.generate(101, (index) => Center(child: Text('${2000 + index}년', style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.onSurface)))),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 원하시는 대로 [월 화 수 목 금 토 일] 순서 고정!
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];

    int daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    // 1(월요일) ~ 7(일요일)
    int firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday; 
    int offset = firstWeekday - 1; // 그리드뷰 앞쪽 빈칸 계산 (월요일 시작이므로 -1)

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 손잡이
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),

            // 🚀 달력 헤더 (년도 선택기 호출 + 이전/다음 달 이동)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => setState(() => _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1)),
                ),
                GestureDetector(
                  onTap: _showYearPicker, // 🚀 년/월 부분을 누르면 드래그 창 팝업!
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_displayedMonth.year}년 ${_displayedMonth.month}월', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                      ]
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 28),
                  onPressed: () => setState(() => _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1)),
                ),
              ]
            ),
            const SizedBox(height: 20),

            // 요일 헤더 (월~일)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                Color color = Colors.grey;
                if (day == '토') color = Color(0xFFF87171);
                if (day == '일') color = Color(0xFFF87171);
                return Expanded(child: Center(child: Text(day, style: TextStyle(color: color, fontWeight: FontWeight.bold))));
              }).toList(),
            ),
            const SizedBox(height: 8),

            // 달력 그리드 (일자)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7일 고정
                childAspectRatio: 1.0, 
              ),
              itemCount: offset + daysInMonth,
              itemBuilder: (context, index) {
                if (index < offset) return const SizedBox.shrink(); // 1일 시작 전 빈칸
                
                int day = index - offset + 1;
                DateTime currentItemDate = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                
                // 선택된 날짜인지, 오늘 날짜인지 판별
                bool isSelected = currentItemDate.year == widget.initialDate.year && currentItemDate.month == widget.initialDate.month && currentItemDate.day == widget.initialDate.day;
                bool isToday = currentItemDate.year == DateTime.now().year && currentItemDate.month == DateTime.now().month && currentItemDate.day == DateTime.now().day;

                // 주말 색상 처리
                Color textColor = Theme.of(context).colorScheme.onSurface;
                if (currentItemDate.weekday == 6) textColor = Color(0xFFF87171);
                if (currentItemDate.weekday == 7) textColor = Color(0xFFF87171);

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, currentItemDate); // 날짜 누르면 팝업 닫히고 이동!
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}