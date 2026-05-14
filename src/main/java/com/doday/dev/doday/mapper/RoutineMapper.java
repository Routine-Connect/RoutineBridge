package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.Routine;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface RoutineMapper {
    void insert(Routine routine);
    List<Routine> findByUserId(Long id);
    List<Routine> findAllByUserId(Long userId);
    Routine findById(Long id);
    void delete(Long id);
    void update(Routine routine);
    List<Routine> findTodayRoutines(@Param("userId") Long userId, @Param("dayOfWeek") String dayOfWeek); // 오늘 루틴 조회
    List<Routine> findByUserIdAndDayOfWeek(@Param("userId") Long userId, @Param("dayOfWeek") String dayOfWeek);
    void updateOrder(@Param("id") Long id, @Param("sortOrder") int sortOrder);
}
