package com.routinebridge.dev.routinebridge.controller;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stats")
@Api(tags = "Stats", description = "통계 API")
public class StatsController {

    @ApiOperation(value = "월간 통계", notes = "특정 월의 날짜별 루틴 완료 여부")
    @GetMapping("/monthly")
    public void getMonthly(@RequestParam int year, @RequestParam int month) {}

    @ApiOperation(value = "주간 통계", notes = "이번 주 루틴 완료 현황")
    @GetMapping("/weekly")
    public void getWeekly() {}
}
