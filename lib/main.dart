import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
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
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // 알림 
  await NotificationService().initNotification();
  
  // 플러터 엔진 초기화 및 한국어 달력 데이터 로딩 (위에서 초기화했으니 바로 달력 로드!)
  await initializeDateFormatting('ko_KR', null); 
  
  // 🚀 카카오 SDK 초기화 전에 .env 파일을 먼저 로드!
  await dotenv.load(fileName: ".env");

  // 🚀 환경변수에서 키를 꺼내와서 꽂아넣기!
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '', 
  );

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