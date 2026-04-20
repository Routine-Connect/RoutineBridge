class NotificationSettings {
  final bool isPushEnabled;
  final bool isRoutineNotiEnabled;
  final bool isMarketingEnabled;

  NotificationSettings({
    required this.isPushEnabled,
    required this.isRoutineNotiEnabled,
    required this.isMarketingEnabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isPushEnabled: json['isPushEnabled'] ?? false,
      isRoutineNotiEnabled: json['isRoutineNotiEnabled'] ?? false,
      isMarketingEnabled: json['isMarketingEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPushEnabled': isPushEnabled,
      'isRoutineNotiEnabled': isRoutineNotiEnabled,
      'isMarketingEnabled': isMarketingEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? isPushEnabled,
    bool? isRoutineNotiEnabled,
    bool? isMarketingEnabled,
  }) {
    return NotificationSettings(
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      isRoutineNotiEnabled: isRoutineNotiEnabled ?? this.isRoutineNotiEnabled,
      isMarketingEnabled: isMarketingEnabled ?? this.isMarketingEnabled,
    );
  }
}