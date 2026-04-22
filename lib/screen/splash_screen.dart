import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // 💡 앱 진입 시 필요한 초기화 작업 진행
  Future<void> _initializeApp() async {
    // 1. 알림 권한 묻기
    await Permission.notification.request();

    // 2. 유저가 로고를 볼 수 있도록 약간의 딜레이 (1.5초)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 3. 스토리지에서 JWT 토큰 확인
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadToken();

    if (!mounted) return;

    // 4. 토큰 유무에 따라 라우팅
    if (authProvider.isAuthenticated) {
      
      // 메인 화면으로 넘어가기 '직전'에 내 최신 프로필 정보를 백엔드에서 싹 당겨옵니다!
      await context.read<UserProvider>().loadMyProfile();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 💡 추후 로고가 들어갈 자리 (반드시 .webp 확장자 사용!)
            /*
            Image.asset(
              'assets/images/logo.webp', 
              width: 150,
            ),
            const SizedBox(height: 24),
            */
            const Text(
              "Doday",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            // 테마에 맞는 로딩 인디케이터
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}