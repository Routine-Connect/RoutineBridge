package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.service.StatsService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/stats")
@Api(tags = "Stats", description = "통계 API")
public class StatsController {

    @Autowired
    private StatsService statsService;

    @ApiOperation(value = "월간 통계", notes = "특정 월의 날짜별 루틴 완료 여부")
    @GetMapping("/monthly")
    public ApiResponse<Map<String, Object>> getMonthly(HttpServletRequest request, @RequestParam int year, @RequestParam int month) {
        Long userId = (Long) request.getSession().getAttribute("userId");
        return ApiResponse.success(statsService.getMonthly(userId, year, month));
    }

    @ApiOperation(value = "주간 통계", notes = "이번 주 루틴 완료 현황")
    @GetMapping("/weekly")
    public ApiResponse<Map<String, Object>> getWeekly(HttpServletRequest request) {
        Long userId = (Long) request.getSession().getAttribute("userId");
        return ApiResponse.success(statsService.getWeekly(userId));
    }

    @ApiOperation(value = "스트릭 조회", notes = "현재 연속 성공 일수 및 최장 기록")
    @GetMapping("/streak")
    public ApiResponse<Map<String, Object>> getStreak(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return ApiResponse.success(statsService.getStreak(userId));
    }
}
