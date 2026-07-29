import 'package:flutter/material.dart'; // debugPrint 용도
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // 싱글톤 패턴 적용
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🚀 1. 초기화 (앱 켜질 때 단 한 번 실행)
  Future<void> initNotification() async {
    tz.initializeTimeZones(); 
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); 

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // 🚨 Android 알람 & 푸시 권한 요청
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    // 🚨 iOS 푸시 권한 요청 (누락 부분 보완)
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // 🚀 2. 튼튼한 한국 시간 변환 함수
  tz.TZDateTime _createScheduledDate(String timeStr) {
    final now = tz.TZDateTime.now(tz.local);
    int hour = 9;
    int minute = 0;
    int second = 0;
    
    try {
      final parts = timeStr.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
      if (parts.length > 2) second = int.parse(parts[2]);
    } catch (e) {
      debugPrint("❌ 시간 파싱 에러: $e");
    }

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute, second
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // 🚀 3. 루틴 알림 매일 반복 예약 스케줄러 (Fallback 예외 처리 포함)
  Future<void> scheduleDailyRoutineNotification({
    required int routineId,
    required String title,
    required String alarmTime, 
  }) async {
    await cancelNotification(routineId);

    final scheduledDate = _createScheduledDate(alarmTime);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doday_routine_channel_v2',
      '루틴 알림',
      channelDescription: 'Doday 루틴 시간에 맞춰 푸시 알림을 보냅니다.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,          // 소리 켜기
      enableVibration: true,    // 진동 켜기
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true, // iOS 앱 켜져 있을 때 배너 띄우기
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      // 1차 시도: 정밀 알람 (exactAllowWhileIdle)
      await _localNotifications.zonedSchedule(
        routineId, 
        '루틴 시간이에요!', 
        '$title 시작해볼까요?', 
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
      print('🔔 [정밀 알림 예약 성공] 루틴 ID: $routineId / 예약시간: $scheduledDate');
    } catch (e) {
      // 2차 시도: OS 정책으로 정밀 알람 권한이 차단된 경우, 앱이 튕기거나 실패하지 않고 일반 알람으로 예외 처리
      print('⚠️ [정밀 알람 거부됨] 일반 알람 모드로 자동 전환: $e');
      try {
        await _localNotifications.zonedSchedule(
          routineId, 
          '루틴 시간이에요!', 
          '$title 시작해볼까요?', 
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, 
        );
        print('🔔 [일반 알림 예약 성공 (Fallback)] 루틴 ID: $routineId / 예약시간: $scheduledDate');
      } catch (fallbackError) {
        print('❌ [알림 예약 최종 실패] 루틴 ID: $routineId / 에러: $fallbackError');
      }
    }
  }

  Future<void> cancelNotification(int routineId) async {
    await _localNotifications.cancel(routineId);
    print('🔕 [알림 예약 취소] 루틴 ID: $routineId');
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('🚨 [모든 알림 일괄 삭제 완료]');
  }
}