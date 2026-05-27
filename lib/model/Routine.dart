import 'package:flutter/material.dart';

class Routine {
  final int id;
  final int userId;
  final String title;
  final String daysOfWeek;
  final TimeOfDay? alarmTime;
  final bool isActive;
  final int iconId;
  final int sortOrder;
  final bool isAlarmEnabled;

  Routine({
    required this.id,
    required this.userId,
    required this.title,
    required this.daysOfWeek,
    this.alarmTime,
    required this.isActive,
    required this.iconId,
    required this.sortOrder,
    this.isAlarmEnabled = false,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '이름 없음',
      daysOfWeek: json['days_of_week'] ?? '',
      alarmTime: json['alarm_time'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      iconId: json['icon_id'] ?? 1, 
      sortOrder: json['sort_order'] ?? 0,
      isAlarmEnabled: json['is_alarm_enabled'] == false || json['is_alarm_enabled'] == 0,
    );
  }
}