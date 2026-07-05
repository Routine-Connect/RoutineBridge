package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.service.KakaoService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Api(tags = "Auth", description = "소셜 로그인 API")
public class KakaoController {

    @Autowired
    private KakaoService kakaoService;



    @ApiOperation(value = "카카오 로그인", notes = "카카오 액세스 토큰으로 로그인")
    @PostMapping("/kakao")
    public ApiResponse<Map<String, Object>> kakaoLogin(@RequestBody Map<String, String> body) {
        String accessToken = body.get("accessToken");
        Map<String, Object> result = kakaoService.kakaoLogin(accessToken);
        return ApiResponse.success(result);
    }
}
