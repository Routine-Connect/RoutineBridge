import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/statistics_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'provider/routine_provider.dart';
import 'ui/screen/splash_screen.dart';
import 'service/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async { 
  // 스플래시 화면이 앱 초기화 동안 유지되도록 설정
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await NotificationService().initNotification();
  // 플러터 엔진 초기화 및 한국어 달력 데이터 로딩
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('ko_KR', null); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), 
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Doday',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData, 
          
          home: const SplashScreen(),
        );
      },
    );
  }
}