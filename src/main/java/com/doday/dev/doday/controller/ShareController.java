package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.service.ShareService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api")
@Api(tags = "Share", description = "공유 API")
public class ShareController {

    @Autowired
    private ShareService shareService;

    @ApiOperation(value = "공유 토큰 발급", notes = "나의 기록 공유 URL 생성")
    @GetMapping("/stats/share/token")
    public ApiResponse<String> generateShareToken(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return ApiResponse.success(shareService.generateShareToken(userId));
    }

    @ApiOperation(value = "공유 데이터 조회", notes = "공유 URL로 통계 데이터 조회 (인증 불필요)")
    @GetMapping("/share/{token}")
    public ApiResponse<Map<String, Object>> getShareData(@PathVariable String token) {
        return ApiResponse.success(shareService.getShareData(token));
    }
}
