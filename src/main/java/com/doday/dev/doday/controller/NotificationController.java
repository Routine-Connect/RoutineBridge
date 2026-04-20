package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.domain.NotificationSettings;
import com.doday.dev.doday.dto.NotificationSettingsDto;
import com.doday.dev.doday.service.NotificationService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/users/me/notifications")
@Api(tags = "Notification", description = "알림 설정 API")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;
    
    @ApiOperation(value = "알림 설정 조회", notes = "내 알림 설정 상태 조회")
    @GetMapping
    public ApiResponse<NotificationSettings> getSettings(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return ApiResponse.success(notificationService.getSettings(userId));
    }

    @ApiOperation(value = "알림 설정 변경", notes = "알림 설정 토글")
    @PutMapping
    public ApiResponse<NotificationSettings> updateSettings(HttpServletRequest request, @RequestBody NotificationSettingsDto dto) {
        Long userId = (Long) request.getAttribute("userId");
        return ApiResponse.success(notificationService.updateSettings(userId, dto));
    }
}
