package com.doday.dev.doday.domain;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class RoutineLog {
    private Long id;
    private Long routineId;
    private String checkDate;
    private boolean isCompleted;
}
