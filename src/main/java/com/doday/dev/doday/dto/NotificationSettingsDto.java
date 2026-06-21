package com.doday.dev.doday.dto;

import lombok.Data;

@Data
public class NotificationSettingsDto {


    private Boolean isPushEnabled;
    private Boolean isRoutineNotiEnabled;
    private Boolean isMarketingEnabled;
}
