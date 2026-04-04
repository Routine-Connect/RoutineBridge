package com.routinebridge.dev.routinebridge.domain;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class Routine {
    private Long id;
    private Long userId;
    private String title;
    private String daysOfWeek;
    private String alarmTime;
    private Boolean isActive;
    private String createdAt;
}
