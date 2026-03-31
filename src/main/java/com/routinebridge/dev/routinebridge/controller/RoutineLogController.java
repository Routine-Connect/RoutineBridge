package com.routinebridge.dev.routinebridge.controller;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/routines")
@Api(tags = "RoutineLog", description = "루틴 체크 API")
public class RoutineLogController {

    @ApiOperation(value = "루틴 완료 체크", notes = "루틴 완료 토글(완료 / 미완료)")
    @PostMapping("/{id}/check")
    public void checkRoutine(@PathVariable Long id) {}
}
