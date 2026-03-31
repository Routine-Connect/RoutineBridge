package com.routinebridge.dev.routinebridge.mapper;

import com.routinebridge.dev.routinebridge.domain.Routine;

import java.util.List;

public interface RoutineMapper {
    void insert(Routine routine);
    List<Routine> findByUserId(Long id);
    Routine findById(Long id);
    void delete(Long id);
    void update(Routine routine);
    List<Routine> findTodayRoutines(Long userId, String dayOfWeek); // 오늘 루틴 조회
}
