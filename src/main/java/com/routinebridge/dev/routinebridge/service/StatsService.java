package com.routinebridge.dev.routinebridge.service;

import com.routinebridge.dev.routinebridge.domain.Routine;
import com.routinebridge.dev.routinebridge.domain.RoutineLog;
import com.routinebridge.dev.routinebridge.mapper.RoutineLogMapper;
import com.routinebridge.dev.routinebridge.mapper.RoutineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Year;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StatsService {

    @Autowired
    private RoutineMapper routineMapper;

    @Autowired
    private RoutineLogMapper routineLogMapper;

    // 월간 통계
    public Map<String, Object> getMonthly(Long userId, int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        String startDate = ym.atDay(1).toString();
        String endDate = ym.atEndOfMonth().toString();

        List<Routine> routines = routineMapper.findByUserId(userId);
        Map<String, Object> result = new HashMap<>();

        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate
            );
            result.put(String.valueOf(routine.getId()), logs);
        }
        return result;
    }

    // 주간 통계
    public Map<String, Object> getWeekly(Long userId) {
        LocalDate today = LocalDate.now();
        String startDate = today.minusDays(6).toString();
        String endDate = today.toString();

        List<Routine> routines = routineMapper.findByUserId(userId);
        Map<String, Object> result = new HashMap<>();

        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate
            );
            result.put(String.valueOf(routine.getId()), logs);
        }
        return result;
    }
}
