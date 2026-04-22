import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'provider/routine_provider.dart';
import 'screen/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async { 
  // 플러터 엔진 초기화 및 한국어 달력 데이터 로딩
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('ko_KR', null); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), 
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
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