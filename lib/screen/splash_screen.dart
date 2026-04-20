import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart'; // 하단 네비게이션바가 있는 메인 화면

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
    // 1. 알림 권한 묻기 (시스템 팝업 호출)
    await Permission.notification.request();

    // 2. 유저가 로고를 볼 수 있도록 약간의 딜레이 (1.5초)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 3. 스토리지에서 JWT 토큰 확인 (자동 로그인)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadToken();

    if (!mounted) return;

    // 4. 토큰 유무에 따라 목적지로 라우팅 (pushReplacement로 뒤로가기 방지)
    if (authProvider.isAuthenticated) {
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
    // 💡 초기화 로직이 도는 동안 유저에게 보여줄 화면
    return Scaffold(
      backgroundColor: Colors.black, // Doday 테마 색상으로 변경 가능
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 이미지
            Image.asset(
              'assets/images/quokka.webp', 
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            // 부드러운 로딩 인디케이터
            const CircularProgressIndicator(color: Colors.white), 
          ],
        ),
      ),
    );
  }
}