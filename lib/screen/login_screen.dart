import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../theme/app_colors.dart';
import '../widget/custom_snackbar.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

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

    // 빈 칸 검사
    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.show(
        context, 
        message: '이메일과 비밀번호를 모두 입력해주세요.', 
        isError: true,
      );
      return;
    }

    setState(() { _isLoading = true; });

    // Provider의 login 함수 호출 (내부적으로 Service가 돌아감)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final errorMessage = await authProvider.login(email, password);

    if (!mounted) return; 
    
    setState(() { _isLoading = false; });

    if (errorMessage == null) {
      // 성공 시에는 유저 정보를 불러오는 로직을 실행한 후 메인 화면으로 이동
      await Provider.of<UserProvider>(context, listen: false).loadMyProfile();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // 실패 시 커스텀 에러 스낵바 표시
      CustomSnackBar.show(
        context, 
        message: errorMessage, 
        isError: true,
      );
    }
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
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 로그인 버튼
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
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 🚀 회원가입 유도 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '아직 계정이 없으신가요?',
                        style: TextStyle(color: AppColors.onSurface),
                      ),
                      TextButton(
                        onPressed: () {
                          // 회원가입 화면으로 부드럽게 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary, 
                          ),
                        ),
                      ),
                    ],
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