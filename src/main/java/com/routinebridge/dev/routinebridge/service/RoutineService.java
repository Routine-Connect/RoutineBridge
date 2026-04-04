package com.routinebridge.dev.routinebridge.service;

import com.routinebridge.dev.routinebridge.common.ErrorCode;
import com.routinebridge.dev.routinebridge.domain.Routine;
import com.routinebridge.dev.routinebridge.mapper.RoutineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

@Service
public class RoutineService {

    @Autowired
    private RoutineMapper routineMapper;

    // 루틴 생성
    public void create(Routine routine) {
        routineMapper.insert(routine);
    }

    // 루틴 목록 조회
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

}
