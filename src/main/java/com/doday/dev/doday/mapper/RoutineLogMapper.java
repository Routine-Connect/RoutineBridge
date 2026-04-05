package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.RoutineLog;
import org.apache.ibatis.annotations.Param;

import java.util.List;


public interface RoutineLogMapper {
    void insert(RoutineLog log);
    RoutineLog findByRoutineIdAndDate(@Param("routineId") Long routineId, @Param("checkDate") String checkDate);
    void updateCompleted(@Param("routineId") Long routineId, @Param("checkDate") String checkDate, @Param("isCompleted") boolean isCompleted);
    List<RoutineLog> findByRoutineIdAndPeriod(@Param("routineId") Long routineId, @Param("startDate") String startDate, @Param("endDate") String endDate);  // 통계용
}
