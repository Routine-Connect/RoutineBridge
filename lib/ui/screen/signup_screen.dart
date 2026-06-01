import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import '../../util/api_error_handler.dart';
import '../theme/app_colors.dart';
import '../widget/custom_snackbar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  String _selectedGender = 'm'; // 기본 성별 설정 ('m' 또는 'w')

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signupToServer() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String passwordConfirm = _passwordConfirmController.text;
    final String nickname = _nicknameController.text.trim();

    // 1. 빈 칸 검사
    if (email.isEmpty || password.isEmpty || passwordConfirm.isEmpty || nickname.isEmpty) {
      CustomSnackBar.show(context, message: '모든 항목을 입력해주세요.', isError: true);
      return;
    }

    // 2. 비밀번호 일치 검사
    if (password != passwordConfirm) {
      CustomSnackBar.show(context, message: '비밀번호가 일치하지 않습니다.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    await ApiErrorHandler.execute(
      context,
      () async {
        final authService = AuthService();
        await authService.signup(email, password, nickname, _selectedGender);
      },
      onSuccess: () {
        if (!mounted) return;
        CustomSnackBar.show(context, message: '🎉 환영합니다! 회원가입이 완료되었습니다.');
        Navigator.of(context).pop();
      },
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.webp',
              fit: BoxFit.cover,
            ),
          ),
          
          // 뒤로 가기 버튼
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 회원가입 폼
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '계정 만들기',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 닉네임 입력
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: '닉네임',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    // 비밀번호 확인
                    TextField(
                      controller: _passwordConfirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호 확인',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 성별 선택 영역
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('성별', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('남성'),
                          selected: _selectedGender == 'm',
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          onSelected: (bool selected) {
                            if (selected) setState(() => _selectedGender = 'm');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('여성'),
                          selected: _selectedGender == 'w',
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          onSelected: (bool selected) {
                            if (selected) setState(() => _selectedGender = 'w');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 회원가입 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signupToServer,
                        child: _isLoading 
                            ? const SizedBox(
                                width: 24, 
                                height: 24, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              )
                            : const Text(
                                '가입하기',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}