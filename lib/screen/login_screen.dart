import 'dart:convert'; // JSON 변환용
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:routine_app/provider/auth_provider.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 💡 통신 중인지 확인하는 상태 변수 (버튼 연타 방지 및 로딩 뺑뺑이용)
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🚀 로그인 버튼 함수
  Future<void> _loginToServer() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // 💡 1. Provider(두뇌)를 불러와서 로그인 로직을 대신 시킴!
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 💡 2. Provider가 통신을 끝내고 에러가 있으면 에러 메시지를, 성공하면 null을 줌
    final errorMessage = await authProvider.login(email, password);

    setState(() { _isLoading = false; });

    // 💡 3. 결과에 따른 화면 처리
    if (!mounted) return; // 위젯이 안전한지 확인하는 실무 필수 코드

    if (errorMessage == null) {
      // 성공 시: 스낵바 띄우고 메인 화면으로 이동 (pushReplacement)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 로그인 성공!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // 실패 시: 에러 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.webp',
              fit: BoxFit.cover,
            ),
          ),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // 💡 로딩 중일 때는 버튼 비활성화(null), 아닐 때는 통신 함수 실행
                      onPressed: _isLoading ? null : _loginToServer,
                      
                      // 💡 로딩 중이면 빙글빙글 도는 아이콘, 아니면 '로그인' 글자 표시
                      child: _isLoading 
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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