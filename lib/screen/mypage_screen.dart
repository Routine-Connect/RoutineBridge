import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:routine_app/screen/login_screen.dart';
import '../theme/app_style.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
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
                  colors: [AppStyle.primary, AppStyle.primaryContainer],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppStyle.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppStyle.surfaceContainerLowest,
                  border: Border.all(
                    color: AppStyle.surfaceContainerLowest,
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
            // 편집 버튼
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppStyle.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: AppStyle.plushShadow,
                border: Border.all(
                  color: AppStyle.surfaceContainer,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit,
                color: AppStyle.primary,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '행복한 쿼카',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppStyle.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '오늘도 포근한 하루 보내세요!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppStyle.onSurfaceVariant,
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
              color: AppStyle.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppStyle.streakOrange.withOpacity(0.1)),
              boxShadow: AppStyle.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppStyle.streakOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppStyle.streakOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '연속 기록',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '12일',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppStyle.streakOrange,
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
              color: AppStyle.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppStyle.primary.withOpacity(0.05)),
              boxShadow: AppStyle.plushShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppStyle.tertiaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppStyle.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '완료 루틴',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '48개',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppStyle.onSurface,
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
              color: AppStyle.secondary,
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
            activeColor: AppStyle.primary,
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

        // 3. 고객센터
        const _SettingTile(
          icon: Icons.support_agent,
          title: '고객센터',
          showChevron: true,
        ),
        const SizedBox(height: 16),

        // 4. 로그아웃 (포인트 컬러 적용)
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
        ? AppStyle.logoutCoral.withOpacity(0.1) 
        : AppStyle.primaryFixed.withOpacity(0.5);
    final Color iconColor = isDestructive 
        ? AppStyle.logoutCoral 
        : AppStyle.onSurfaceVariant;
    final Color titleColor = isDestructive 
        ? AppStyle.secondary 
        : AppStyle.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: AppStyle.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyle.plushShadow,
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
                    color: AppStyle.outlineVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}