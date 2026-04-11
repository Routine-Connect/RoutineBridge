package com.doday.dev.doday.service;

import com.doday.dev.doday.domain.Routine;
import com.doday.dev.doday.domain.RoutineLog;
import com.doday.dev.doday.mapper.RoutineLogMapper;
import com.doday.dev.doday.mapper.RoutineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@Service
public class CalendarService {

    @Autowired
    private RoutineMapper routineMapper;

    @Autowired
    private RoutineLogMapper routineLogMapper;

    public Map<String, List<Map<String, Object>>> getMonthlyCalendar(Long userId, int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        String startDate = ym.atDay(1).toString();
        String endDate = ym.atEndOfMonth().toString();

        // 전체 루틴 가져오기 (비활성 포함 - 과거 기록 표시)
        List<Routine> routines = routineMapper.findByUserId(userId);

        // 날짜별 루틴 로그 미리 수집
        Map<String, Map<Long, Boolean>> logMap = new HashMap<>();
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(routine.getId(), startDate, endDate);
            for (RoutineLog log : logs) {
                logMap
                        .computeIfAbsent(log.getCheckDate(), k -> new HashMap<>())
                        .put(log.getRoutineId(), log.isCompleted());
            }
        }

        // 날짜별 루틴 목록 구성
        Map<String, List<Map<String, Object>>> result = new LinkedHashMap<>();

        for (int d = 1; d <= ym.lengthOfMonth(); d++) {
            LocalDate date = ym.atDay(d);
            String dateStr = date.toString();
            String dayOfWeek = date.getDayOfWeek().name().substring(0, 3);  // MON , TUE , WED
            List<Map<String, Object>> dayRoutines = new ArrayList<>();

            for (Routine routine : routines) {
                // 해당 요일에 해당하는 루틴만
                if (!routine.getDaysOfWeek().contains(dayOfWeek)) continue;

                Map<String, Object> routineMap = new LinkedHashMap<>();
                routineMap.put("id", routine.getId());
                routineMap.put("title", routine.getTitle());
                routineMap.put("alarmTime", routine.getAlarmTime());
                routineMap.put("isActive", routine.getIsActive());


                // 완료 여부
                boolean isCompleted = logMap.getOrDefault(dateStr, Collections.emptyMap())
                        .getOrDefault(routine.getId(), false);
                routineMap.put("isCompleted", isCompleted);

                dayRoutines.add(routineMap);
            }

            // 루틴 있는 날짜만 포함
            if (!dayRoutines.isEmpty()) {
                result.put(dateStr, dayRoutines);
            }
        }
        return result;
    }
}
