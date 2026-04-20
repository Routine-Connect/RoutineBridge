import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import 'custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../provider/user_provider.dart';

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
                const Text(
                  '닉네임 변경',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '새로운 닉네임을 입력하세요',
                    hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // 입력된 텍스트를 반환하며 모달 닫기
                        Navigator.pop(context, controller.text);
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

  // 🚀 2. 루틴 아이콘 선택 바텀시트 (20개 IconData로 변경)
  static Future<IconData?> showIconPickerBottomSheet(BuildContext context) async {
    // 실무에서 자주 쓰이는 루틴 관련 아이콘 20개 매핑
    final List<IconData> routineIcons = [
      Icons.water_drop, Icons.fitness_center, Icons.directions_run, Icons.menu_book,
      Icons.self_improvement, Icons.apple, Icons.computer, Icons.bed,
      Icons.brush, Icons.music_note, Icons.shopping_cart, Icons.cleaning_services,
      Icons.local_cafe, Icons.wb_sunny, Icons.nights_stay, Icons.pets,
      Icons.attach_money, Icons.flight, Icons.favorite, Icons.star,
    ];

    return showModalBottomSheet<IconData>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '루틴 아이콘 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 20개이므로 가로 5개 x 세로 4줄 배치가 깔끔함
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: routineIcons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.pop(context, routineIcons[index]), // 선택한 아이콘 반환
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        routineIcons[index],
                        color: AppColors.primary, // 테마 컬러 적용
                        size: 28,
                      ),
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

  // 🚀 3. 루틴 추가 바텀시트 (텍스트 입력 + 아이콘 픽커 호출)
  static Future<void> showAddRoutineBottomSheet(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.star; // 기본 아이콘 설정

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 화면이 밀려올라가도록 설정
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        // StatefulBuilder를 사용해야 바텀시트 내부에서 아이콘 변경 상태를 즉각 반영할 수 있음
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              // 키보드 높이만큼 여백을 주기 위한 패딩 설정
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새로운 루틴 추가',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 아이콘 선택 버튼 + 루틴명 입력창
                  Row(
                    children: [
                      // 아이콘 선택 영역
                      GestureDetector(
                        onTap: () async {
                          // 💡 위에서 만든 아이콘 픽커 바텀시트를 호출!
                          final IconData? pickedIcon = await showIconPickerBottomSheet(context);
                          if (pickedIcon != null) {
                            setState(() => selectedIcon = pickedIcon); // 선택된 아이콘으로 업데이트
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Icon(selectedIcon, color: AppColors.primary, size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 루틴명 입력 영역
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: '루틴 이름을 입력하세요',
                            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                            filled: true,
                            fillColor: AppColors.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // 추가하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // TODO: 입력된 nameController.text와 selectedIcon 데이터를 백엔드 API로 전송하는 로직 추가
                        Navigator.pop(context); // 닫기
                      },
                      child: const Text('루틴 추가하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
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


  // 🚀 비밀번호 변경 모달 (Center Dialog)
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
                  decoration: InputDecoration(
                    hintText: '새로운 비밀번호',
                    filled: true, fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
                    filled: true, fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
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

  // 🔔 알림 설정 메뉴를 누를 때 호출되는 함수
  static Future<void> showNotificationSettingsBottomSheet(BuildContext context) async {
    // 1. 바텀 시트 열기 전에 먼저 권한 상태 확인
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // 🚨 거부 상태라면? -> OS 권한 팝업을 다시 띄움
      status = await Permission.notification.request();
      // 만약 팝업 떴는데 또 거절하면 바텀 시트 안 열고 종료
      if (!status.isGranted && !status.isPermanentlyDenied) return;
    }

    if (status.isPermanentlyDenied) {
      // 🚨 '항상 거부' 상태라면? -> 설정창으로 유도하는 안내창 띄움
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림 권한 필요'),
          content: const Text('스마트폰 설정에서 알림 권한을 허용해 주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            TextButton(
              onPressed: () {
                openAppSettings(); // 기기 설정창 열기
                Navigator.pop(context);
              }, 
              child: const Text('설정으로 이동')
            ),
          ],
        ),
      );
      return; // 설정창 안내를 띄웠으므로 바텀 시트는 열지 않음
    }

    // 2. 권한이 허용된 상태라면 서버에서 데이터를 불러오고 바텀 시트를 엽니다.
    if (!context.mounted) return;
    Provider.of<UserProvider>(context, listen: false).loadNotificationSettings();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final settings = userProvider.notificationSettings;

            if (settings == null) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('알림 세부 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  
                  // 스위치 로직은 기존과 동일 (이미 위에서 권한을 받았으므로 바로 통신)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('앱 알림 전체 켜기'),
                    subtitle: const Text('앱에서 보내는 모든 알림을 제어합니다.'),
                    value: settings.isPushEnabled,
                    onChanged: (value) {
                      final newSettings = settings.copyWith(
                        isPushEnabled: value,
                        isRoutineNotiEnabled: value ? settings.isRoutineNotiEnabled : false,
                        isMarketingEnabled: value ? settings.isMarketingEnabled : false,
                      );
                      userProvider.updateNotification(newSettings);
                    },
                  ),
                  const Divider(),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('루틴 리마인더'),
                    value: settings.isRoutineNotiEnabled,
                    onChanged: settings.isPushEnabled ? (value) {
                      userProvider.updateNotification(settings.copyWith(isRoutineNotiEnabled: value));
                    } : null,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('이벤트 및 혜택 알림'),
                    value: settings.isMarketingEnabled,
                    onChanged: settings.isPushEnabled ? (value) {
                      userProvider.updateNotification(settings.copyWith(isMarketingEnabled: value));
                    } : null,
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
}