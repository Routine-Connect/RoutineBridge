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

    // 🚨 [복구된 핵심 코드] 정밀 알람 & 푸시 권한 요청 (이거 없으면 제시간에 안 울림!)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // 🚀 2. 튼튼한 한국 시간 변환 함수 (새로 추가)
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

  // 🚀 3. 루틴 알림 매일 반복 예약 스케줄러
  Future<void> scheduleDailyRoutineNotification({
    required int routineId,
    required String title,
    required String alarmTime, 
  }) async {
    await cancelNotification(routineId);

    // 🚀 방금 만든 튼튼한 함수 사용!
    final scheduledDate = _createScheduledDate(alarmTime);

    // 🚨 [가장 중요한 수정] 채널 ID를 v2로 변경하고 소리/진동 강제 켜기!
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doday_routine_channel_v2', // 👈 무조건 새 이름이어야 폰이 속음!!
      '루틴 알림',
      channelDescription: 'Doday 루틴 시간에 맞춰 푸시 알림을 보냅니다.',
      importance: Importance.max, // 화면 가리는 헤드업 배너용
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
      await _localNotifications.zonedSchedule(
        routineId, 
        '🔔루틴 시간이에요!', 
        '$title 시작해볼까요?', 
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 절전 모드에서도 알림이 정해진 시간에 울리도록 강제함
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
      print('🔔 [알림 예약 성공] 루틴 ID: $routineId / 예약시간: $scheduledDate');
    } catch (e) {
      print('❌ [알림 예약 실패] 권한 문제 또는 스케줄러 에러: $e');
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