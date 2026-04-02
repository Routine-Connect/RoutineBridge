package com.routinebridge.dev.routinebridge.controller;

import com.routinebridge.dev.routinebridge.common.ApiResponse;
import com.routinebridge.dev.routinebridge.domain.RoutineLog;
import com.routinebridge.dev.routinebridge.service.RoutineLogService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/routines")
@Api(tags = "RoutineLog", description = "루틴 체크 API")
public class RoutineLogController {

    @Autowired
    private RoutineLogService routineLogService;

    @ApiOperation(value = "루틴 완료 체크", notes = "루틴 완료 토글(완료 / 미완료)")
    @PostMapping("/{id}/check")
    public ApiResponse<Void> checkRoutine(@PathVariable Long id, @RequestBody RoutineLog log) {
        log.setRoutineId(id);
        routineLogService.check(log);
        return ApiResponse.success(null);
    }
}
