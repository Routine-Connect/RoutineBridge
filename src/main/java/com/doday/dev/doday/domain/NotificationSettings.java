package com.doday.dev.doday.domain;

import lombok.Data;

@Data
public class NotificationSettings {
    private Long id;
    private Long userId;
    private Boolean isPushEnabled;
    private Boolean isRoutineNotiEnabled;
    private Boolean isMarketingEnabled;
    private String createdAt;
}
