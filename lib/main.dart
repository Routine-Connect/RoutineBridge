import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/provider/auth_provider.dart';
import 'package:routine_app/screen/login_screen.dart';
import 'package:routine_app/screen/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      // ..loadToken()을 호출해서 앱이 켜지자마자 금고에서 토큰을 꺼내오게 함
      create: (context) => AuthProvider()..loadToken(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doday',
      // 💡 [핵심] Consumer를 통해 로그인 상태(isAuthenticated)에 따라 첫 화면을 결정함
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // 1. 토큰이 메모리에 올라와 있다면(로그인 상태라면) 바로 메인 화면으로!
          if (auth.isAuthenticated) {
            return MainScreen();
          }
          // 2. 토큰이 없다면 시작 화면(MyHomePage)을 보여줌
          return const MyHomePage();
        },
      ),
    );
  }
}

// 시작 화면 (Landing Page)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Doday',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '작은 습관이 내일의 나를 만듭니다',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 화면으로 이동할 때는 스택에 쌓아줌 (push)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold)),
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