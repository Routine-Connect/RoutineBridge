package com.doday.dev.doday.service;

import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.domain.Routine;
import com.doday.dev.doday.domain.RoutineLog;
import com.doday.dev.doday.dto.RoutineOrderDto;
import com.doday.dev.doday.mapper.RoutineLogMapper;
import com.doday.dev.doday.mapper.RoutineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@Service
public class RoutineService {

    @Autowired
    private RoutineMapper routineMapper;

    @Autowired
    private RoutineLogMapper routineLogMapper;

    // 루틴 생성
    public void create(Routine routine) {
        routineMapper.insert(routine);
    }

    // 루틴 목록 조회 (활성만)
    public List<Routine> getAll(Long userid) {
        return routineMapper.findByUserId(userid);
    }

    // 루틴 단건 조회
    public Routine getOne(Long id, Long userid) {
        Routine routine = routineMapper.findById(id);
        if (routine == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }

        if (!routine.getUserId().equals(userid)) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_FORBBIDEN.getMessage());
        }
        return routine;
    }

    // 특정날짜 필터링 후, 루틴 조회
    public List<Map<String, Object>> getDailyRoutines(Long userId, String date) {
        // 날짜 파싱
        LocalDate localDate = LocalDate.parse(date);
        String dayOfWeek = localDate.getDayOfWeek().name().substring(0, 3); // MON, TUE ...

        // 해당 요일 루틴 조회
        List<Routine> routines = routineMapper.findByUserIdAndDayOfWeek(userId, dayOfWeek);

        // 해당 날짜 로그 조회
        List<Map<String, Object>> result = new ArrayList<>();
        for (Routine routine : routines) {
            RoutineLog log = routineLogMapper.findByRoutineIdAndDate(routine.getId(), date);

            // 루틴 생성일 이전 날짜 제외
            String routineCreatedDate = routine.getCreatedAt().substring(0, 10);
            if (localDate.isBefore(LocalDate.parse(routineCreatedDate))) continue;

            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", routine.getId());
            map.put("title", routine.getTitle());
            map.put("alarmTime", routine.getAlarmTime());
            map.put("iconId", routine.getIconId());
            map.put("daysOfWeek", routine.getDaysOfWeek());
            map.put("isCompleted", log != null && log.isCompleted());
            result.add(map);
        }

        return result;
    }

    // 한달치 루틴 조회
    public Map<String, Object> getMonthlyRoutines(Long userId, int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        String startDate = ym.atDay(1).toString();
        String endDate = ym.atEndOfMonth().toString();

        List<Routine> routines = routineMapper.findByUserId(userId);

        // 해당 월 로그 미리 수집
        Map<String, Map<Long, Boolean>> logMap = new HashMap<>();
        for (Routine routine : routines) {
            List<RoutineLog> logs = routineLogMapper.findByRoutineIdAndPeriod(
                    routine.getId(), startDate, endDate);
            for (RoutineLog log : logs) {
                logMap.computeIfAbsent(log.getCheckDate(), k -> new HashMap<>())
                        .put(log.getRoutineId(), log.isCompleted());
            }
        }

        // 날짜별 루틴 구성
        Map<String, List<Map<String, Object>>> daily = new LinkedHashMap<>();
        int totalRoutineCount = 0;
        int completedRoutineCount = 0;

        for (int d = 1; d <= ym.lengthOfMonth(); d++) {
            LocalDate date = ym.atDay(d);
            String dateStr = date.toString();
            String dayOfWeek = date.getDayOfWeek().name().substring(0, 3);

            List<Map<String, Object>> dayRoutines = new ArrayList<>();

            for (Routine routine : routines) {
                if (!routine.getIsActive()) continue;
                if (!routine.getDaysOfWeek().contains(dayOfWeek)) continue;


                // 루틴 생성일 이전 날짜 제외
                String routineCreatedDate = routine.getCreatedAt().substring(0, 10);
                if (date.isBefore(LocalDate.parse(routineCreatedDate))) continue;

                Map<String, Object> map = new LinkedHashMap<>();
                map.put("id", routine.getId());
                map.put("title", routine.getTitle());
                map.put("alarmTime", routine.getAlarmTime());
                map.put("iconId", routine.getIconId());
                map.put("daysOfWeek", routine.getDaysOfWeek());

                boolean isCompleted = logMap
                        .getOrDefault(dateStr, Collections.emptyMap())
                        .getOrDefault(routine.getId(), false);
                map.put("isCompleted", isCompleted);

                dayRoutines.add(map);

                // 이번달 루틴 총개수 / 완료 개수 집계
                totalRoutineCount++;
                if (isCompleted) completedRoutineCount++;
            }

            daily.put(dateStr, dayRoutines);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("daily", daily);
        result.put("totalRoutineCount", totalRoutineCount);
        result.put("completedRoutineCount", completedRoutineCount);
        return result;
    }


    // 루틴 수정
    public void update(Routine routine, Long userId) {
        Routine existing = routineMapper.findById(routine.getId());
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }

        if (!existing.getUserId().equals(userId)) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_FORBBIDEN.getMessage());
        }
        routineMapper.update(routine);
    }

    // 루틴 삭제
    public void delete(Long id, Long userid) {
        Routine existing = routineMapper.findById(id);
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }

        if (!existing.getUserId().equals(userid)) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_FORBBIDEN.getMessage());
        }
        routineMapper.delete(id);
    }
    
    // 오늘의 루틴 조회
    public List<Routine> getToday(Long userid) {
        DayOfWeek dayOfWeek = LocalDate.now().getDayOfWeek();
        String day = dayOfWeek.name().substring(0, 3); // MON , TUE, WED
        return routineMapper.findTodayRoutines(userid, day);
    }


    public void updateOrder(Long userId, List<RoutineOrderDto> orderList) {
        for (RoutineOrderDto dto : orderList) {
            Routine routine = routineMapper.findById(dto.getId());
            if (routine == null) {
                throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
            }
            if (!routine.getUserId().equals(userId)) {
                throw new IllegalArgumentException(ErrorCode.ROUTINE_FORBBIDEN.getMessage());
            }
            routineMapper.updateOrder(dto.getId(), dto.getSortOrder());
        }
    }

}
