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
    public void check(RoutineLog log) {

        // 루틴 활성화 여부 확인
        Routine routine = routineMapper.findById(log.getRoutineId());
        if (routine == null) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_NOT_FOUND.getMessage());
        }
        if (!routine.getIsActive()) {
            throw new IllegalArgumentException(ErrorCode.ROUTINE_INACTIVE.getMessage());
        }


        String today = LocalDate.now().toString();
        log.setCheckDate(today);

        RoutineLog existing = routineLogMapper.findByRoutineIdAndDate(log.getRoutineId(), today);

        if (existing == null) {
            // 오늘 처음 체크 -> 새로 생성
            log.setCompleted(true);
            routineLogMapper.insert(log);
        } else {
            // 이미 있으면 토글
            routineLogMapper.updateCompleted(log.getRoutineId(), today, !existing.isCompleted());
        }
    }
}
