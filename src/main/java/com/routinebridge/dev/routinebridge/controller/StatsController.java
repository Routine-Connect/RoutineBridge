package com.routinebridge.dev.routinebridge.controller;

import com.routinebridge.dev.routinebridge.common.ApiResponse;
import com.routinebridge.dev.routinebridge.service.StatsService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/stats")
@Api(tags = "Stats", description = "통계 API")
public class StatsController {

    @Autowired
    private StatsService statsService;

    @ApiOperation(value = "월간 통계", notes = "특정 월의 날짜별 루틴 완료 여부")
    @GetMapping("/monthly")
    public ApiResponse<Map<String, Object>> getMonthly(@RequestParam Long userId, @RequestParam int year, @RequestParam int month) {
        return ApiResponse.success(statsService.getMonthly(userId, year, month));
    }

    @ApiOperation(value = "주간 통계", notes = "이번 주 루틴 완료 현황")
    @GetMapping("/weekly")
    public ApiResponse<Map<String, Object>> getWeekly(@RequestParam Long userId) {
        return ApiResponse.success(statsService.getWeekly(userId));
    }
}
