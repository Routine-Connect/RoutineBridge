import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:routine_app/screen/login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../widget/app_modal.dart';
import '../widget/custom_snackbar.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 32),
          const _ProfileSection(),
          const SizedBox(height: 40),
          const _StatsGrid(),
          const SizedBox(height: 40),
          const _SettingsSection(),
          const SizedBox(height: 200), // 바텀 네비게이션바 여백
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // 프로필 아바타 (글로우 효과 포함)
            Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/quokka.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // 1. 프로필 이미지 수정 버튼
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: AppShadows.plushShadow,
                border: Border.all(
                  color: AppColors.surfaceContainer,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 🚀 2. 닉네임과 버튼 영역 (양팔 저울 기법으로 완벽한 중앙 정렬 + 터치 오류 해결)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💡 [핵심] 왼쪽 빈 공간: 오른쪽(간격 8 + 버튼 약 26)과 동일한 너비를 주어 중앙 정렬을 강제함
            const SizedBox(width: 34), 
            
            // 닉네임 텍스트 (완벽한 정중앙에 위치함)
            const Text(
              '행복한 쿼카',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            
            // 오른쪽 간격 + 실제 버튼
            const SizedBox(width: 8),
            GestureDetector(
              // 버튼 클릭 영역을 확실하게 넓혀주기 위해 HitTestBehavior 추가
              behavior: HitTestBehavior.opaque, 
              onTap: () async {
                // 모달창 호출
                final newNickname = await AppModals.showNicknameEditDialog(
                  context,
                  currentNickname: '행복한 쿼카', // 임시 텍스트
                );

                if (!context.mounted) return;

                if (newNickname != null && newNickname.isNotEmpty) {
                  // TODO: 나중에 Provider 통해서 서버 데이터 갱신 로직 추가
                  
                  // 스낵바 알림 호출
                  CustomSnackBar.show(
                    context,
                    message: '닉네임이 성공적으로 변경되었습니다.',
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.plushShadow,
                  border: Border.all(
                    color: AppColors.surfaceContainer,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // 닉네임과 인사말 간격 추가
        
        // 3. 인사말 텍스트 (단독 배치)
        const Text(
          '오늘도 포근한 하루 보내세요!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 연속 기록 카드
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.streakOrange.withOpacity(0.1)),
              boxShadow: AppShadows.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.streakOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.streakOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '연속 기록',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '12일',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.streakOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 완료 루틴 카드
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.05)),
              boxShadow: AppShadows.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '완료 루틴',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '48개',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '계정 설정',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 1. 알림 설정 (토글 스위치)
        _SettingTile(
          icon: Icons.notifications,
          title: '알림 설정',
          trailing: CupertinoSwitch(
            value: true,
            activeColor: AppColors.primary,
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 8),

        // 2. 테마 설정
        const _SettingTile(
          icon: Icons.palette,
          title: '테마 설정',
          showChevron: true,
        ),
        const SizedBox(height: 8),

        // 3. 비밀번호 변경
        const _SettingTile(
          icon: Icons.lock,
          title: '비밀번호 변경',
          showChevron: true,
          onTap: null,
        ),
        const SizedBox(height: 16),

        // 4. 고객센터
        const _SettingTile(
          icon: Icons.support_agent,
          title: '고객센터',
          showChevron: true,
          onTap: null, // 나중에 고객센터 페이지로 이동하는 기능 추가 예정
        ),
        const SizedBox(height: 16),

        // 5. 로그아웃 (포인트 컬러 적용)
        _SettingTile(
          icon: Icons.logout,
          title: '로그아웃',
          isDestructive: true,
          showChevron: true,
          onTap: () async {
            // 💡 1. Provider를 불러와서 토큰 삭제(로그아웃) 심부름을 시킵니다.
            await Provider.of<AuthProvider>(context, listen: false).logout();

            // 위젯이 안전한 상태인지 확인 (실무 필수)
            if (!context.mounted) return;

            // 💡 2. 로그인 화면으로 이동시키면서, 기존 쌓여있던 화면 기록을 싹 다 날립니다!
            // (안 그러면 유저가 스마트폰 '뒤로 가기'를 눌렀을 때 다시 마이페이지로 들어오는 대참사가 발생함)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, 
            );
          },
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.showChevron = false,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconBgColor = isDestructive 
        ? AppColors.logoutCoral.withOpacity(0.1) 
        : AppColors.primaryFixed.withOpacity(0.5);
    final Color iconColor = isDestructive 
        ? AppColors.logoutCoral 
        : AppColors.onSurfaceVariant;
    final Color titleColor = isDestructive 
        ? AppColors.secondary 
        : AppColors.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.plushShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.outlineVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}