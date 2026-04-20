import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(
    // 💡 앱 전체에서 쓸 Provider들을 여기서 묶어서 등록해 줍니다.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doday',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard', // 폰트 설정 (필요시)
        useMaterial3: true,
      ),
      // 🚀 앱이 켜지면 무조건 SplashScreen부터 띄웁니다!
      home: const SplashScreen(),
    );
  }
}