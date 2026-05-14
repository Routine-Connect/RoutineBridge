package com.doday.dev.doday.service;

import com.doday.dev.doday.domain.Routine;
import com.doday.dev.doday.domain.RoutineLog;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.mapper.RoutineLogMapper;
import com.doday.dev.doday.mapper.RoutineMapper;
import com.doday.dev.doday.mapper.UserMapper;
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

    @Autowired
    private UserMapper userMapper;

    // 월간 통계
    public Map<String, Object> getMonthly(Long userId, int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        String startDate = ym.atDay(1).toString();
        String endDate = ym.atEndOfMonth().toString();

        List<Routine> routines = routineMapper.findByUserId(userId);

        Map<String, Integer> doneCount = new LinkedHashMap<>();
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate);
            for (RoutineLog log : logs) {
                if (log.isCompleted()) {
                    doneCount.merge(log.getCheckDate(), 1, Integer::sum);
                }
            }
        }

        Map<String, Object> dailyResult = new LinkedHashMap<>();
        int totalRoutineCount = 0;
        int completedRoutineCount = 0;

        for (int d = 1; d <= ym.lengthOfMonth(); d++) {
            LocalDate date = ym.atDay(d);
            String dateStr = date.toString();
            String dayOfWeek = date.getDayOfWeek().name().substring(0, 3);

            int totalForDay = (int) routines.stream()
                    .filter(r -> Boolean.TRUE.equals(r.getIsActive()))
                    .filter(r -> r.getDaysOfWeek().contains(dayOfWeek))
                    .count();

            if (totalForDay == 0) {
                dailyResult.put(dateStr, 0.0);
            } else {
                int done = doneCount.getOrDefault(dateStr, 0);
                double pct = Math.round((done * 100.0 / totalForDay) * 10) / 10.0;
                dailyResult.put(dateStr, pct);
            }

            // 이번달 총개수 / 완료 개수 집계
            totalRoutineCount += totalForDay;
            completedRoutineCount += doneCount.getOrDefault(dateStr, 0);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("daily", dailyResult);
        result.put("totalRoutineCount", totalRoutineCount);
        result.put("completedRoutineCount", completedRoutineCount);
        return result;
    }

    // 주간 통계
    public Map<String, Object> getWeekly(Long userId) {
        LocalDate today = LocalDate.now();
        String startDate = today.minusDays(6).toString();
        String endDate = today.toString();

        List<Routine> routines = routineMapper.findByUserId(userId);

        Map<String, Integer> doneCount = new LinkedHashMap<>();
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate);
            for (RoutineLog log : logs) {
                if (log.isCompleted()) {
                    doneCount.merge(log.getCheckDate(), 1, Integer::sum);
                }
            }
        }

        Map<String, Object> dailyResult = new LinkedHashMap<>();
        int totalRoutineCount = 0;
        int completedRoutineCount = 0;

        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String dateStr = date.toString();
            String dayOfWeek = date.getDayOfWeek().name().substring(0, 3);

            int totalForDay = (int) routines.stream()
                    .filter(r -> Boolean.TRUE.equals(r.getIsActive()))
                    .filter(r -> r.getDaysOfWeek().contains(dayOfWeek))
                    .count();

            if (totalForDay == 0) {
                dailyResult.put(dateStr, 0.0);
            } else {
                int done = doneCount.getOrDefault(dateStr, 0);
                double pct = Math.round((done * 100.0 / totalForDay) * 10) / 10.0;
                dailyResult.put(dateStr, pct);
            }

            totalRoutineCount += totalForDay;
            completedRoutineCount += doneCount.getOrDefault(dateStr, 0);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("daily", dailyResult);
        result.put("totalRoutineCount", totalRoutineCount);
        result.put("completedRoutineCount", completedRoutineCount);
        return result;
    }


    // 스트릭 계산
    public Map<String, Object> getStreak(Long userId) {
        System.out.println("getStreak userId = " + userId);

        String startDate = YearMonth.now().atDay(1).toString();
        String endDate = LocalDate.now().toString();

        List<Routine> routines = routineMapper.findAllByUserId(userId);

        System.out.println("루틴 개수 : " + routines.size());

        Map<String, Integer> totalPerDay = new HashMap<>();
        Map<String, Integer> donePerDay = new HashMap<>();
        int totalCompleted = 0;

        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate
            );
            System.out.println("루틴 ID : " +  routine.getId() + " 로그 개수 : " + logs.size());
            for (RoutineLog log : logs) {
                System.out.println("날짜 : " + log.getCheckDate() + " 완료 : " + log.isCompleted());
                totalPerDay.merge(log.getCheckDate(), 1, Integer::sum);
                if (log.isCompleted()) {
                    donePerDay.merge(log.getCheckDate(), 1, Integer::sum);
                    totalCompleted++;
                }
            }
        }

        // 전부 완료한 날만 completedDates에 추가
        Set<String> completedDates = new HashSet<>();
        for (String d : totalPerDay.keySet()) {
            int total = totalPerDay.get(d);
            int done = donePerDay.getOrDefault(d, 0);
            if (total == done) {
                completedDates.add(d);
            }
        }

        // 현재 스트릭 계산
        int currentStreak = 0;
        LocalDate date = LocalDate.now();

        if (!completedDates.contains(date.toString())) {
            date = date.minusDays(1);
        }

        while (completedDates.contains(date.toString())) {
            currentStreak++;
            date = date.minusDays(1);
        }

        // 최장 스트릭 계산
        int longestStreak = 0;
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
            longestStreak = Math.max(tempStreak, longestStreak);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("currentStreak", currentStreak);
        result.put("longestStreak", longestStreak);
        result.put("totalCompleted", totalCompleted);
        return result;
    }
}
