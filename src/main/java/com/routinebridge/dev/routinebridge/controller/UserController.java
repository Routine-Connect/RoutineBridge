package com.routinebridge.dev.routinebridge.controller;

import com.routinebridge.dev.routinebridge.domain.User;
import com.routinebridge.dev.routinebridge.common.ApiResponse;
import com.routinebridge.dev.routinebridge.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@Api(tags = "User", description = "사용자 인증 API")
public class UserController {

    @Autowired
    UserService userService;

    @ApiOperation(value = "회원가입", notes = "이메일, 비밀번호, 닉네임으로 회원가입")
    @PostMapping("/signup")
    public ApiResponse<Void> signup(@RequestBody User user) {
        userService.signup(user);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "로그인", notes = "이메일, 비밀번호로 로그인 후 JWT 반환")
    @PostMapping("/login")
    public ApiResponse<String> login(@RequestBody User user) {
        String token = userService.login(user);
        return ApiResponse.success(token);
    }

    @ApiOperation(value = "프로필 수정", notes = "닉네임, 비밀번호 수정")
    @PostMapping("/me")
    public ApiResponse<Void> updateProfile(@RequestBody User user) {
        userService.updateProfile(user);
        return ApiResponse.success(null);
    }
}
