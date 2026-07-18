import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/util/api_error_handler.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../theme/app_colors.dart';
import '../widget/custom_snackbar.dart';
import 'main_screen.dart';
import 'signup_screen.dart';
import 'gender_onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginToServer() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // 🚀 1. 이메일 빈 칸 검사
    if (email.isEmpty) {
      CustomSnackBar.show(context, message: '이메일을 입력해주세요.', isError: true);
      return;
    }

    // 🚀 2. 이메일 형식 검사
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      CustomSnackBar.show(context, message: '올바른 이메일 형식을 입력해주세요.', isError: true);
      return;
    }

    // 🚀 3. 비밀번호 빈 칸 검사
    if (password.isEmpty) {
      CustomSnackBar.show(context, message: '비밀번호를 입력해주세요.', isError: true);
      return;
    }

    // 🚀 4. 비밀번호 최소 길이 검사
    if (password.length < 4) {
      CustomSnackBar.show(context, message: '비밀번호는 4자리 이상입니다.', isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    await ApiErrorHandler.execute(
      context,
      () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(email, password);
        
        await Provider.of<UserProvider>(context, listen: false).loadMyProfile();
      },
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
    );

    if (mounted) setState(() { _isLoading = false; });
  }

  // 🚀 카카오 로그인 버튼 눌렀을 때 실행될 함수
  Future<void> _loginWithKakao() async {
    await ApiErrorHandler.execute(
      context,
      () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Provider한테 카카오 로그인 시키고 결과를 받아옴
        String result = await authProvider.loginWithKakao();
        
        if (result == 'NEW_USER') {
          // 🚀 신규 유저면 아까 만든 '성별 온보딩 화면'으로 이동!
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GenderOnboardingScreen()),
          );
        } else if (result == 'EXISTING_USER') {
          // 🚀 기존 유저면 유저 정보 로드하고 바로 '홈 화면'으로 이동!
          await Provider.of<UserProvider>(context, listen: false).loadMyProfile();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.webp',
              fit: BoxFit.cover,
            ),
          ),
          
          // 로그인 폼 영역
          Center(                                    
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '환영합니다!',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 이메일 입력
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 비밀번호 입력
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loginToServer(),
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 🚀 1. 일반 이메일 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _loginToServer,
                      child: _isLoading 
                          ? const SizedBox(
                              width: 24, height: 24, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 회원가입 유도 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '아직 계정이 없으신가요?',
                        style: TextStyle(color: AppColors.onSurface),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary, 
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 🚀 2. '또는' 구분선 (UI 디테일)
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('또는', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🚀 3. 카카오 소셜 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500), // 카카오 공식 브랜드 노란색
                        foregroundColor: Colors.black87, // 카카오 공식 글자색
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loginWithKakao,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/kakao_login.webp',
                            width: 200, // 카카오 가이드라인에 최적화된 심볼 크기
                            height: 100,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}