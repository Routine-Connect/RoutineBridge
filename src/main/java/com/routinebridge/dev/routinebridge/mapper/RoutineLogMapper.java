package com.routinebridge.dev.routinebridge.mapper;

import com.routinebridge.dev.routinebridge.domain.RoutineLog;

import java.util.List;


public interface RoutineLogMapper {
    void insert(RoutineLog log);
    RoutineLog findByRoutineIdAndDate(Long routineId, String checkDate);
    void updateCompleted(Long routineId, String checkDate, boolean isCompleted);
    List<RoutineLog> findByRoutineIdAndPeriod(Long routineId, String startDate, String endDate);    // 통계용
}
