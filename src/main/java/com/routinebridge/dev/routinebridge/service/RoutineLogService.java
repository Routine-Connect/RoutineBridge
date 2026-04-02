package com.routinebridge.dev.routinebridge.service;

import com.routinebridge.dev.routinebridge.domain.RoutineLog;
import com.routinebridge.dev.routinebridge.mapper.RoutineLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class RoutineLogService {


    @Autowired
    private RoutineLogMapper routineLogMapper;


    // 루틴 완료 체크 (토글)
    public void check(RoutineLog log) {
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
