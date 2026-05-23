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
        Routine routine = routineMapper.findById(routineId);
        if (routine == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }

        if (!routine.getUserId().equals(userId)) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_FORBBIDEN.getMessage());
        }

        if (!routine.getIsActive()) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_INACTIVE.getMessage());
        }

        String checkDate = (date != null && !date.isEmpty()) ? date : LocalDate.now().toString();

        // 루틴 생성일 이전 날짜 체크 방지
        String routineCreatedDate = routine.getCreatedAt().substring(0, 10);
        if (LocalDate.parse(checkDate).isBefore(LocalDate.parse(routineCreatedDate))) {
            throw new IllegalArgumentException(ErrorCode.INVALID_INPUT.getMessage());
        }

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
