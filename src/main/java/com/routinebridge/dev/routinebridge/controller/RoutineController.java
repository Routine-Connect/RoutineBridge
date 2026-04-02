package com.routinebridge.dev.routinebridge.controller;


import com.routinebridge.dev.routinebridge.common.ApiResponse;
import com.routinebridge.dev.routinebridge.domain.Routine;
import com.routinebridge.dev.routinebridge.service.RoutineService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routines")
@Api(tags = "Routine", description = "루틴 관리 API")
public class RoutineController {

    @Autowired
    private RoutineService routineService;

    @ApiOperation(value = "루틴 생성", notes = "새 루틴 추가")
    @PostMapping
    public ApiResponse<Void> create(@RequestBody Routine routine) {
        routineService.create(routine);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "루틴 목록 조회", notes = "유저의 전체 루틴 조회")
    @GetMapping
    public ApiResponse<List<Routine>> getAll(@RequestParam Long userId) {
        return ApiResponse.success(routineService.getAll(userId));
    }

    @ApiOperation(value = "루틴 수정", notes = "루틴 정보 수정")
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable Long id, @RequestBody Routine routine) {
        routine.setId(id);
        routineService.update(routine);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "루틴 삭제", notes = "루틴 삭제")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        routineService.delete(id);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "오늘의 루틴 조회", notes = "오늘 요일에 해당하는 루틴만 조회")
    @GetMapping("/today")
    public ApiResponse<List<Routine>> getToday(@RequestParam Long userId) {
        return ApiResponse.success(routineService.getToday(userId));
    }
}
