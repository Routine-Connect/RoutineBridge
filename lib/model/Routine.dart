import 'package:flutter/material.dart';

class Routine {
  final int id;
  final String title;
  final String dayOfWeek;
  final TimeOfDay? alarmTime;
  final bool isActive;

  Routine({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    this.alarmTime,
    required this.isActive
  });
}