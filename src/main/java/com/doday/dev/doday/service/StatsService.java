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

        // 날짜별 완료 여부 집계
        Map<String, Boolean> dailyResult = new LinkedHashMap<>();


        // 해당 월 날짜 전부 초기화 (false)
        for (int d= 1; d<= ym.lengthOfMonth(); d++) {
            String date = ym.atDay(d).toString();
            dailyResult.put(date, false);
        }

        // 루틴 로그 확인해서 하루라도 완료된 날 true
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate
            );
            for (RoutineLog log : logs) {
                if (log.isCompleted()) {
                    dailyResult.put(log.getCheckDate(), true);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("daily", dailyResult);
        return result;
    }

    // 주간 통계
    public Map<String, Object> getWeekly(Long userId) {
        LocalDate today = LocalDate.now();
        String startDate = today.minusDays(6).toString();
        String endDate = today.toString();

        List<Routine> routines = routineMapper.findByUserId(userId);

        // 날짜별 완료 여부
        Map<String, Boolean> dailyResult = new LinkedHashMap<>();
        for (int i = 6; i >=0; i--) {
            dailyResult.put(today.minusDays(i).toString(), false);
        }

        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate
            );
            for (RoutineLog log : logs) {
                if (log.isCompleted()) {
                    dailyResult.put(log.getCheckDate(), true);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("daily", dailyResult);
        return result;
    }


    // 스트릭 계산
    public Map<String, Object> getStreak(Long userId) {
        List<Routine> routines = routineMapper.findByUserId(userId);

        // 전체 로그 날짜 중 완료된 날짜 Set으로 수집
        Set<String> completedDates = new HashSet<>();
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), "2000-01-01", LocalDate.now().toString()
            );
            for (RoutineLog log : logs) {
                if (log.isCompleted()) {
                    completedDates.add(log.getCheckDate());
                }
            }
        }

        // 현재 스트릭 계산
        int currentStreak = 0;
        LocalDate date = LocalDate.now();
        while (!completedDates.contains(date.toString())) {
            currentStreak++;
            date = date.minusDays(1);
        }


        // 최장 스트릭 계산
        int logestStreak = 0;
        int tempStreak = 0;
        List<String> sortedDates = new ArrayList<>(completedDates);
        Collections.sort(sortedDates);

        for (int i = 0; i < sortedDates.size(); i++) {
            if (i == 0) {
                tempStreak = 1;
            } else {
                LocalDate prev = LocalDate.parse(sortedDates.get(i - 1));
                LocalDate curr = LocalDate.parse(sortedDates.get(i));
                if (curr.equals(prev.plusDays(1))) {
                    tempStreak++;
                } else {
                    tempStreak = 1;
                }
            }
            logestStreak = Math.max(tempStreak, logestStreak);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("currentStreak", currentStreak);
        result.put("longestStreak", logestStreak);
        return result;
    }
}
