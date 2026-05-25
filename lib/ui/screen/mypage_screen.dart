import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/provider/routine_provider.dart';
import 'package:routine_app/provider/statistics_provider.dart';
import 'package:routine_app/provider/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../widget/app_modal.dart';
import '../widget/custom_snackbar.dart';
import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 화면 뼈대가 그려진 직후, 비동기 초기화 함수를 실행합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMyPage();
    });
  }

  // 🚀 비동기(async)로 작동하는 전체 기간 통계 로딩 로직
  Future<void> _initializeMyPage() async {
    final statsProvider = context.read<StatisticsProvider>();
    
    // 🚀 마이페이지에 필요한 전체 기간 스트릭/누적 완료 데이터를 서버에서 불러옵니다.
    await statsProvider.loadAllTimeStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 32),
          _ProfileSection(),
          SizedBox(height: 40),
          _StatsGrid(),
          SizedBox(height: 40),
          _SettingsSection(),
          SizedBox(height: 200),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    
    final String currentNickname = user?.nickname ?? '로딩중...';
    final String? profileImageUrl = user?.profileImage;
    final String currentGender = user?.gender ?? 'm'; 
    final bool isMale = currentGender == 'm';
    final IconData genderIcon = isMale ? Icons.male_rounded : Icons.female_rounded;
    final Color genderColor = isMale ? AppColors.statSkyDark : AppColors.logoutCoral;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 128, height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer], begin: Alignment.topRight, end: Alignment.bottomLeft),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLowest, border: Border.all(color: AppColors.surfaceContainerLowest, width: 4)),
                child: ClipOval(
                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? Image.network(profileImageUrl, fit: BoxFit.cover)
                      : Image.asset('assets/images/quokka.webp', fit: BoxFit.cover),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null && context.mounted) {
                  try {
                    await context.read<UserProvider>().updateProfileImage(File(pickedFile.path));
                    CustomSnackBar.show(context, message: '프로필 이미지가 변경되었습니다.');
                  } catch (e) {
                    CustomSnackBar.show(context, message: e.toString().replaceAll('Exception: ', ''), isError: true);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle, boxShadow: AppShadows.getPlushShadow(context), border: Border.all(color: AppColors.surfaceContainer, width: 1)),
                child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle, boxShadow: AppShadows.getPlushShadow(context), border: Border.all(color: AppColors.surfaceContainer, width: 1)),
              child: Icon(genderIcon, color: genderColor, size: 12),
            ),
            const SizedBox(width: 8), 
            Text(currentNickname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.5)),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque, 
              onTap: () async {
                final newNickname = await AppModals.showNicknameEditDialog(context, currentNickname: currentNickname);
                if (!context.mounted) return;
                if (newNickname != null && newNickname.isNotEmpty && newNickname != currentNickname) {
                  try {
                    await context.read<UserProvider>().updateNickname(newNickname);
                    CustomSnackBar.show(context, message: '닉네임이 성공적으로 변경되었습니다.');
                  } catch (e) {
                    CustomSnackBar.show(context, message: e.toString().replaceAll('Exception: ', ''), isError: true);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle, boxShadow: AppShadows.getPlushShadow(context), border: Border.all(color: AppColors.surfaceContainer, width: 1)),
                child: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), 
        const Text('오늘도 포근한 하루 보내세요!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    // 🚀 Provider를 구독하여 실제 통계 데이터를 실시간으로 가져옵니다.
    final statsProvider = context.watch<StatisticsProvider>();
    final int longestStreak = statsProvider.allTimeStreak?['longestStreak'] ?? 0; // 전체 최장 기록
    final int totalCompleted = statsProvider.allTimeStreak?['totalCompleted'] ?? 0; // 전체 누적 완료 루틴 수

    return Row(
      children: [
        // 1. 연속 기록 카드
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: AppColors.streakOrange.withOpacity(0.1)), 
              boxShadow: AppShadows.getPlushShadow(context)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32, 
                  decoration: BoxDecoration(color: AppColors.streakOrange.withOpacity(0.1), shape: BoxShape.circle), 
                  child: const Icon(Icons.local_fire_department, color: AppColors.streakOrange, size: 20)
                ),
                const SizedBox(height: 12),
                const Text('최장 기록', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                const SizedBox(height: 2),
                // 최장 기록
                Text('$longestStreak일', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.streakOrange)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 2. 완료 루틴 카드
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)), 
              boxShadow: AppShadows.getPlushShadow(context)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32, 
                  decoration: const BoxDecoration(color: AppColors.tertiaryFixed, shape: BoxShape.circle), 
                  child: const Icon(Icons.check_circle, color: AppColors.tertiary, size: 20)
                ),
                const SizedBox(height: 12),
                const Text('완료 루틴', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                const SizedBox(height: 2),
                // 완료 루틴
                Text('$totalCompleted개', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('계정 설정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 1.5))),
        const SizedBox(height: 16),
        _SettingTile(
          icon: Icons.notifications,
          title: '알림 설정',
          showChevron: true,
          onTap: () {
            AppModals.showNotificationSettingsBottomSheet(context);
          },
        ),
        const SizedBox(height: 8),
        _SettingTile(
          icon: Icons.palette, 
          title: '테마 설정', 
          showChevron: true, 
          onTap: () {
            AppModals.showThemeSelectBottomSheet(context);
          },
        ),
        const SizedBox(height: 8),
        _SettingTile(
          icon: Icons.lock, title: '비밀번호 변경', showChevron: true,
          onTap: () async {
            final newPassword = await AppModals.showPasswordEditDialog(context);
            if (!context.mounted) return;
            if (newPassword != null && newPassword.isNotEmpty) {
              try {
                await context.read<UserProvider>().updatePassword(newPassword);
                CustomSnackBar.show(context, message: '비밀번호가 안전하게 변경되었습니다.');
              } catch (e) {
                CustomSnackBar.show(context, message: e.toString().replaceAll('Exception: ', ''), isError: true);
              }
            }
          },
        ),
        const SizedBox(height: 16),
        const _SettingTile(icon: Icons.support_agent, title: '고객센터', showChevron: true),
        const SizedBox(height: 16),
        _SettingTile(
          icon: Icons.logout, title: '로그아웃', isDestructive: true, showChevron: true,
          onTap: () async {
            try{
              await context.read<AuthProvider>().logout();  // 토큰 삭제
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            } catch (e) {
              if (!context.mounted) return;
              debugPrint('서버 로그아웃 실패 (서버 꺼짐 등), 하지만 로컬 로그아웃은 진행합니다.');
            } finally {
              // 2. 🚀 서버 에러와 상관없이 로컬 데이터는 무조건 싹 비움! (가장 중요)
              context.read<UserProvider>().clearUser();  
              context.read<RoutineProvider>().clearRoutines();  
              context.read<StatisticsProvider>().clearStats();  
              context.read<ThemeProvider>().clearTheme();  

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()), 
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, this.trailing, this.showChevron = false, this.isDestructive = false, this.onTap});
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconBgColor = isDestructive ? AppColors.logoutCoral.withOpacity(0.1) : Theme.of(context).colorScheme.primaryFixed.withOpacity(0.5);
    final Color iconColor = isDestructive ? AppColors.logoutCoral : AppColors.onSurfaceVariant;
    final Color titleColor = isDestructive ? AppColors.secondary : AppColors.onSurface;

    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.getPlushShadow(context)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor))),
                if (trailing != null) trailing!,
                if (showChevron) const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}