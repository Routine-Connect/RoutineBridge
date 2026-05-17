package com.doday.dev.doday.service;

import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.domain.Routine;
import com.doday.dev.doday.domain.RoutineLog;
import com.doday.dev.doday.mapper.RoutineLogMapper;
import com.doday.dev.doday.mapper.RoutineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class RoutineLogService {


    @Autowired
    private RoutineLogMapper routineLogMapper;

    @Autowired
    private RoutineMapper routineMapper;


    // 루틴 완료 체크 (토글)
    public void check(Long routineId, Long userId, String date) {
        System.out.println("check 호출 - routineId: " + routineId + " date: " + date);
        Routine routine = routineMapper.findById(routineId);
        if (routine == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }
        if (!routine.getIsActive()) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_INACTIVE.getMessage());
        }

        // 본인 루틴인지 확인
        if (!routine.getUserId().equals(userId)) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_UNAUTHORIZED.getMessage());
        }

        if (!routine.getIsActive()) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_INACTIVE.getMessage());
        }


        // date 없으면 오늘 날짜
        String checkDate = (date != null && !date.isEmpty()) ? date : LocalDate.now().toString();

        RoutineLog existing = routineLogMapper.findByRoutineIdAndDate(routineId, checkDate);

        if (existing == null) {
            RoutineLog log = new RoutineLog();
            log.setRoutineId(routineId);
            log.setCheckDate(checkDate);
            log.setCompleted(true);
            routineLogMapper.insert(log);
        } else {
            routineLogMapper.updateCompleted(routineId, checkDate, !existing.isCompleted());
        }
    }
}
