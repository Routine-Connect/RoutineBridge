import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    _controller = VideoPlayerController.asset('assets/images/quokka_splash.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
        
        // 💡 2. 영상이 화면에 그려질 준비가 끝났으므로 네이티브 스플래시를 걷어냅니다!
        FlutterNativeSplash.remove(); 
        
      }).catchError((error) {
        debugPrint("💡 비디오 초기화 에러 발생: $error");
        
        // 💡 3. 에러가 나더라도 앱이 멈추면 안 되므로 여기서도 걷어내 줍니다.
        FlutterNativeSplash.remove(); 
      });

    _initializeApp();
  }

  @override
  void dispose() {
    // 💡 메모리 누수 방지를 위한 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 🚀 1. 앱 켜질 때 필요한 권한 3종 세트 강제 획득! (알림, 배터리 제한 해제, 정밀 알람)
    await _checkAndRequestPermissions();

    // 쿼카 인사를 충분히 볼 수 있도록 최소 1.5초 대기
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadToken();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
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

  // 안드로이드 14 알림 씹힘 방지 권한 요청 함수
  Future<void> _checkAndRequestPermissions() async {
    // 1. 일반 알림 권한 (헤드업 배너)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. 정밀 알람 권한 (안드로이드 12 이상 스케줄러 필수 권한)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 💡 비디오 재생 영역
            SizedBox(
              width: 150,
              height: 150,
              child: _isInitialized
                  ? VideoPlayer(_controller)
                  : const SizedBox.shrink(), // 초기화 전에는 빈 공간
            ),
            const SizedBox(height: 24),
            Text(
              "Doday",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}