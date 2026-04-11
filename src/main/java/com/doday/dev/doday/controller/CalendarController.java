package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.service.CalendarService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/calendar")
@Api(tags = "캘린더", description = "캘린더 API")
public class CalendarController {

    @Autowired
    private CalendarService calendarService;

    @ApiOperation(value = "월간 캘린더", notes = "날짜별 루틴 목록 조회")
    @GetMapping("/monthly")
    public ApiResponse<Map<String, List<Map<String, Object>>>> getMonthlyCalendar(
            @RequestParam int year,
            @RequestParam int month,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return ApiResponse.success(calendarService.getMonthlyCalendar(userId, year, month));
    }
}
